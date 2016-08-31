module Spree
  module Stock
    ContentItem.class_eval do
      delegate :has_product_packages?, to: :variant, prefix: true
    end
  end
end
