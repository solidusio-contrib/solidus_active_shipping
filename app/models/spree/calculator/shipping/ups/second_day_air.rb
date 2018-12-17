module Spree
  module Calculator::Shipping
    module Ups
      class SecondDayAir < Spree::Calculator::Shipping::Ups::Base
        def self.description
          I18n.t('spree.ups.second_day_air')
        end
      end
    end
  end
end
