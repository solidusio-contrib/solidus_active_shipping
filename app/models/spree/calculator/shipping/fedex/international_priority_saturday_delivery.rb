require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class InternationalPrioritySaturdayDelivery < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.intl_priority_saturday_delivery")
        end
      end
    end
  end
end
