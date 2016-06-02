module Spree
  class PackageBuilder
    extend Forwardable

    attr_reader :shipping_calculator
    attr_accessor :max_weight

    def_instance_delegator :shipping_calculator, :max_weight_for_country

    def initialize(shipping_calculator)
      @shipping_calculator = shipping_calculator
    end

    def process(solidus_package)
      # We compute and set the max_weight once, at the beginning of the process
      @max_weight = get_max_weight(solidus_package)

      packages(solidus_package)
    end

    # Configuration 
    def units
      Spree::ActiveShipping::Config[:units].to_sym
    end

    def multiplier
      Spree::ActiveShipping::Config[:unit_multiplier]
    end

    def default_weight
      Spree::ActiveShipping::Config[:default_weight]
    end

    def max_weight_per_package
      Spree::ActiveShipping::Config[:max_weight_per_package] * multiplier
    end

    private

    def convert_package_to_weights_array(solidus_package)
      weights = solidus_package.contents.map do |content_item|
        item_weight = content_item.weight
        item_weight = default_weight if item_weight <= 0
        item_weight *= multiplier

        if (item_weight > max_weight) && max_weight > 0
          raise Spree::ShippingError, "#{I18n.t(:shipping_error)}: The maximum per package weight for the selected service from the selected country is #{max_weight} ounces."
        end

        item_weight
      end

      weights.compact
    end

    # Used for calculating Dimensional Weight pricing.
    # Override in your own extensions to compute package dimensions,
    # or just leave this alone to keep the default behavior.
    # Sample output: [9, 6, 3]
    def convert_package_to_dimensions_array(_package)
      []
    end

    def convert_package_to_item_packages_array(solidus_package)
      packages = []

      solidus_package.contents.each do |content_item|
        variant  = content_item.variant
        quantity = content_item.quantity
        product  = variant.product

        product.product_packages.each do |product_package|
          if product_package.weight.to_f <= max_weight || max_weight == 0
            quantity.times do
               packages << product_package
            end
          else
            raise Spree::ShippingError, "#{I18n.t(:shipping_error)}: The maximum per package weight for the selected service from the selected country is #{max_weight} ounces."
          end
        end
      end

      packages
    end

    # Generates an array of Package objects based on the quantities and weights of the variants in the line items
    def packages(solidus_package)
      active_shipping_packages = []
      weights = convert_package_to_weights_array(solidus_package)
      dimensions = convert_package_to_dimensions_array(solidus_package)
      item_specific_packages = convert_package_to_item_packages_array(solidus_package)

      if max_weight <= 0
        active_shipping_packages << ::ActiveShipping::Package.new(weights.sum, dimensions, units: units)
      else
        package_weight = 0
        weights.each do |content_weight|
          if package_weight + content_weight <= max_weight
            package_weight += content_weight
          else
            active_shipping_packages << ::ActiveShipping::Package.new(package_weight, dimensions, units: units)
            package_weight = content_weight
          end
        end
        active_shipping_packages << ::ActiveShipping::Package.new(package_weight, dimensions, units: units) if package_weight > 0
      end

      item_specific_packages.each do |product_package|
        active_shipping_packages << ::ActiveShipping::Package.new(product_package.weight * multiplier, [product_package.length, product_package.width, product_package.height], units: units)
      end

      active_shipping_packages
    end

    def get_max_weight(solidus_package)
      order = solidus_package.order
      order_ship_address_country = order.ship_address.country

      # Default value from calculator
      max_weight = max_weight_for_country(order_ship_address_country)

      # If max_weight is zero or max_weight_per_package is less than max_weight
      # We use the max_weight_per_package instead
      if max_weight.zero? && max_weight_per_package.nonzero?
        return max_weight_per_package
      elsif max_weight > 0 && max_weight_per_package < max_weight && max_weight_per_package > 0
        return max_weight_per_package
      end

      max_weight
    end
  end
end
