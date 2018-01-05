module Spree
  module Calculator::Shipping
    module Fedex
      class TwoDaySaturdayDelivery < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.two_day_saturday_delivery")
        end
      end
    end
  end
end
