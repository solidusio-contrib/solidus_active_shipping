module Spree
  module Calculator::Shipping
    module Fedex
      class TwoDay < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.two_day")
        end
      end
    end
  end
end
