module Spree
  module Calculator::Shipping
    module Fedex
      class ThreeDayFreightSaturdayDelivery < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.three_day_freight_saturday_delivery")
        end
      end
    end
  end
end
