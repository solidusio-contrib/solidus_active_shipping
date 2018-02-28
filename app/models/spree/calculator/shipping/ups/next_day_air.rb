module Spree
  module Calculator::Shipping
    module Ups
      class NextDayAir < Spree::Calculator::Shipping::Ups::Base
        def self.description
          Spree.t("ups.next_day_air")
        end
      end
    end
  end
end
