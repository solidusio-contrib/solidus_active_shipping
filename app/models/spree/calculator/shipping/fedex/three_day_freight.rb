module Spree
  module Calculator::Shipping
    module Fedex
      class ThreeDayFreight < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.three_day_freight")
        end
      end
    end
  end
end
