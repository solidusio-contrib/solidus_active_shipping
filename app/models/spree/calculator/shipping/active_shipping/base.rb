# This is a base calculator for shipping calcualations using the ActiveShipping plugin.  It is not intended to be
# instantiated directly.  Create subclass for each specific shipping method you wish to support instead.
#
# Digest::MD5 is used for cache_key generation.
require 'digest/md5'
require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module ActiveShipping
      class Base < ShippingCalculator
        def self.service_name
          description
        end

        def available?(package)
          # helps the available? method determine
          # if rates are avaiable for this service
          # before calling the carrier for rates
          is_package_shippable?(package)

          !compute(package).nil?
        rescue Spree::ShippingError
          false
        end

        def compute_package(package)
          order = package.order
          max_weight = get_max_weight(package)

          stock_location = package.stock_location

          origin = build_location(stock_location)
          destination = build_location(order.ship_address)

          rates_result = retrieve_rates_from_cache(package, origin, destination, max_weight)

          return nil if rates_result.is_a?(Spree::ShippingError)
          return nil if rates_result.empty?
          rate = rates_result[self.class.description]

          return nil unless rate
          rate = rate.to_f + (Spree::ActiveShipping::Config[:handling_fee].to_f || 0.0)

          # divide by 100 since active_shipping rates are expressed as cents
          rate / 100.0
        end

        def timing(line_items)
          order = line_items.first.order
          # TODO: Figure out where stock_location is supposed to come from.
          origin = ::ActiveShipping::Location.new(country: stock_location.country.iso,
                                                  city: stock_location.city,
                                                  state: (stock_location.state ? stock_location.state.abbr : stock_location.state_name),
                                                  zip: stock_location.zipcode)
          addr = order.ship_address
          destination = ::ActiveShipping::Location.new(country: addr.country.iso,
                                                       state: (addr.state ? addr.state.abbr : addr.state_name),
                                                       city: addr.city,
                                                       zip: addr.zipcode)
          timings_result = Rails.cache.fetch(cache_key(package) + '-timings') do
            retrieve_timings(origin, destination, packages(order))
          end
          raise timings_result if timings_result.is_a?(Spree::ShippingError)
          return nil if timings_result.nil? || !timings_result.is_a?(Hash) || timings_result.empty?
          timings_result[description]
        end

        protected

        # weight limit in ounces or zero (if there is no limit)
        def max_weight_for_country(_country)
          0
        end

        private

        def get_max_weight(solidus_package)
          order = solidus_package.order

          # Default value from calculator
          max_weight = max_weight_for_country(order.ship_address.country)

          # If max_weight is zero or max_weight_per_package is less than max_weight
          # We use the max_weight_per_package instead
          if max_weight.zero? && max_weight_per_package.nonzero?
            return max_weight_per_package
          elsif max_weight > 0 && max_weight_per_package < max_weight && max_weight_per_package > 0
            return max_weight_per_package
          end

          max_weight
        end

        def package_builder
          @package_builder ||= Spree::PackageBuilder.new
        end

        def max_weight_per_package
          Spree::ActiveShipping::Config[:max_weight_per_package] * Spree::ActiveShipping::Config[:unit_multiplier]
        end

        # check for known limitations inside a package
        # that will limit you from shipping using a service
        def is_package_shippable?(package)
          # check for weight limits on service
          country_weight_error? package
        end

        def country_weight_error?(package)
          max_weight = max_weight_for_country(package.order.ship_address.country)
          raise Spree::ShippingError, "#{I18n.t(:shipping_error)}: The maximum per package weight for the selected service from the selected country is #{max_weight} ounces." unless valid_weight_for_package?(package, max_weight)
        end

        # zero weight check means no check
        # nil check means service isn't available for that country
        def valid_weight_for_package?(package, max_weight)
          return false if max_weight.nil?
          return true if max_weight.zero?
          package.weight <= max_weight
        end

        def retrieve_rates(origin, destination, shipment_packages)
          response = carrier.find_rates(origin, destination, shipment_packages)
          # turn this beastly array into a nice little hash
          rates = response.rates.collect do |rate|
            service_name = rate.service_name.encode('UTF-8')
            [CGI.unescapeHTML(service_name), rate.price]
          end
          rate_hash = Hash[*rates.flatten]
          return rate_hash
        rescue ::ActiveShipping::Error => e
          if [::ActiveShipping::ResponseError].include?(e.class) && e.response.is_a?(::ActiveShipping::Response)
            params = e.response.params
            if params.key?('Response') && params['Response'].key?('Error') && params['Response']['Error'].key?('ErrorDescription')
              message = params['Response']['Error']['ErrorDescription']
            # Canada Post specific error message
            elsif params.key?('eparcel') && params['eparcel'].key?('error') && params['eparcel']['error'].key?('statusMessage')
              message = e.response.params['eparcel']['error']['statusMessage']
            else
              message = e.message
            end
          else
            message = e.message
          end

          error = Spree::ShippingError.new("#{I18n.t(:shipping_error)}: #{message}")
          Rails.cache.write @cache_key, error # write error to cache to prevent constant re-lookups
          raise error
        end

        def retrieve_timings(origin, destination, packages)
          if carrier.respond_to?(:find_time_in_transit)
            response = carrier.find_time_in_transit(origin, destination, packages)
            return response
          end
        rescue ::ActiveShipping::ResponseError => re
          if re.response.is_a?(::ActiveShipping::Response)
            params = re.response.params
            if params.key?('Response') && params['Response'].key?('Error') && params['Response']['Error'].key?('ErrorDescription')
              message = params['Response']['Error']['ErrorDescription']
            else
              message = re.message
            end
          else
            message = re.message
          end

          error = Spree::ShippingError.new("#{I18n.t(:shipping_error)}: #{message}")
          Rails.cache.write @cache_key + '-timings', error # write error to cache to prevent constant re-lookups
          raise error
        end

        def cache_key(package)
          stock_location = package.stock_location.nil? ? '' : "#{package.stock_location.id}-"
          order = package.order
          ship_address = package.order.ship_address
          contents_hash = Digest::MD5.hexdigest(package.contents.map { |content_item| content_item.variant.id.to_s + '_' + content_item.quantity.to_s }.join('|'))
          @cache_key = "#{stock_location}#{carrier.name}-#{order.number}-#{ship_address.country.iso}-#{fetch_best_state_from_address(ship_address)}-#{ship_address.city}-#{ship_address.zipcode}-#{contents_hash}-#{I18n.locale}".delete(' ')
        end

        def fetch_best_state_from_address(address)
          address.state ? address.state.abbr : address.state_name
        end

        def build_location(address)
          ::ActiveShipping::Location.new(country: address.country.iso,
                                         state: fetch_best_state_from_address(address),
                                         city: address.city,
                                         zip: address.zipcode)
        end

        def retrieve_rates_from_cache(package, origin, destination, max_weight)
          Rails.cache.fetch(cache_key(package)) do
            shipment_packages = package_builder.process(package, max_weight)
            # shipment_packages = packages(package)
            if shipment_packages.empty?
              {}
            else
              retrieve_rates(origin, destination, shipment_packages)
            end
          end
        end
      end
    end
  end
end
