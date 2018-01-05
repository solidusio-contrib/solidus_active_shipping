require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class InternationalGround < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.intl_ground")
        end
      end
    end
  end
end
