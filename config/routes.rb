Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :active_shipping_settings, :only => ['show', 'update', 'edit']

    resources :products, :only => [] do
      resources :product_packages
    end
  end
end
