module Spree
  module Calculator::Shipping
    module Fedex
      class PriorityOvernightSaturdayDelivery < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.priority_overnight_saturday_delivery")
        end
      end
    end
  end
end
