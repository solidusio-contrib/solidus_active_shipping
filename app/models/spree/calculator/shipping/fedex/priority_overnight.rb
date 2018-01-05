require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class PriorityOvernight < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.priority_overnight")
        end
      end
    end
  end
end
