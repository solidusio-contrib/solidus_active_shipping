module Spree
  module Calculator::Shipping
    module Ups
      class ThreeDaySelect < Spree::Calculator::Shipping::Ups::Base
        def self.description
          Spree.t("ups.three_day_select")
        end
      end
    end
  end
end
