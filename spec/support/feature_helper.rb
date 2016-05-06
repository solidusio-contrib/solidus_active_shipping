module FeatureHelper
  def add_to_cart(product)
    visit spree.root_path
    click_link product.name
    click_button "Add To Cart"
  end
end
