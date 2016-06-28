Spree::Variant.class_eval do
  delegate :has_product_packages?, to: :product
end
