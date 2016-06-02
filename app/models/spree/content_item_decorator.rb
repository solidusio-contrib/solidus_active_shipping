module Spree
  module Stock
    ContentItem.class_eval do
      def variant_has_product_packages?
	    variant.has_product_packages?
	  end
    end
  end
end