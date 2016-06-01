module PackageHelper
    def build_content_items(variant, quantity, order)
      quantity.times.map {|i| Spree::Stock::ContentItem.new(build_inventory_unit(variant, order)) }
    end

    def build_inventory_unit(variant, order)
      build(:inventory_unit, variant: variant, order: order)
    end
end