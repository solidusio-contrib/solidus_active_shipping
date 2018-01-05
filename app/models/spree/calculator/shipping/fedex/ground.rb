require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class Ground < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.ground")
        end
      end
    end
  end
end
