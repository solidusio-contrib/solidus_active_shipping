require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class InternationalPriorityFreight < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.intl_priority_freight")
        end
      end
    end
  end
end
