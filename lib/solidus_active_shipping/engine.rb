module Spree::ActiveShipping
end
module SolidusActiveShipping
  class Engine < Rails::Engine

    initializer "spree.active_shipping.preferences", :before => :load_config_initializers do |app|
      Spree::ActiveShipping::Config = Spree::ActiveShippingConfiguration.new
    end

    def self.activate
      Dir[File.join(File.dirname(__FILE__), "../../app/models/spree/calculator/**/base.rb")].sort.each do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.to_prepare &method(:activate).to_proc

    initializer "solidus_active_shipping.register.calculators", after: "spree.register.calculators" do |app|
      if app.config.spree.calculators.shipping_methods
        classes = Dir.chdir File.join(File.dirname(__FILE__), "../../app/models") do
          Dir["spree/calculator/**/*.rb"].reject {|path| path =~ /base.rb$/ }.map do |path|
            path.gsub('.rb', '').camelize.constantize
          end
        end

        app.config.spree.calculators.shipping_methods.concat classes
      end
    end

        # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
    initializer "spree.assets.precompile", :group => :all do |app|
      app.config.assets.precompile += %w[
        admin/product_packages/new.js
        admin/product_packages/edit.js
      ]
    end
  end
end
