module Spree
  module Calculator::Shipping
    module Fedex
      class ThreeDayFreight < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          I18n.t('spree.fedex.three_day_freight')
        end
      end
    end
  end
end
