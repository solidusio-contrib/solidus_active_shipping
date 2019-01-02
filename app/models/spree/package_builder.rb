module Spree
  class PackageBuilder
    attr_accessor :max_weight

    def process(solidus_package, max_weight)
      # We compute and set the max_weight once, at the beginning of the process
      @max_weight = max_weight
      to_packages(solidus_package)
    end

    private

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

    def convert_package_to_weights_array(product_with_product_packages)
      weights = product_with_product_packages.map do |content_item|
        item_weight = content_item.weight
        item_weight = default_weight if item_weight <= 0
        item_weight *= multiplier

        if (item_weight > max_weight) && max_weight > 0
          raise Spree::ShippingError, "#{I18n.t('spree.shipping_error')}: The maximum per package weight for the selected service from the selected country is #{max_weight} ounces."
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

    def convert_package_to_item_packages_array(product_with_no_product_packages)
      packages = []

      product_with_no_product_packages.each do |content_item|
        variant  = content_item.variant
        quantity = content_item.quantity
        product  = variant.product

        product.product_packages.each do |product_package|
          if product_package.weight.to_f <= max_weight || max_weight == 0
            quantity.times do
              packages << product_package
            end
          else
            raise Spree::ShippingError, "#{I18n.t('spree.shipping_error')}: The maximum per package weight for the selected service from the selected country is #{max_weight} ounces."
          end
        end
      end

      packages
    end

    # Generates an array of Package objects based on the quantities and weights of the variants in the line items
    def to_packages(solidus_package)
      active_shipping_packages = []

      product_with_product_packages = []
      product_with_no_product_packages = []
      # Product with no associated product packages will be combined in packages based on weight
      # Product with associated product packages will be added individually based on their attributes
      solidus_package.contents.each do |content_item|
        if content_item.variant_has_product_packages?
          product_with_product_packages << content_item
        else
          product_with_no_product_packages << content_item
        end
      end

      weights = convert_package_to_weights_array(product_with_no_product_packages)
      dimensions = convert_package_to_dimensions_array(solidus_package)
      item_specific_packages = convert_package_to_item_packages_array(product_with_product_packages)

      if max_weight <= 0
        active_shipping_packages << ::ActiveShipping::Package.new(weights.sum, dimensions, units: units) unless weights.empty?
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
  end
end
