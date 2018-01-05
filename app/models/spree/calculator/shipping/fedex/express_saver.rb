require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class ExpressSaver < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.express_saver")
        end
      end
    end
  end
end
