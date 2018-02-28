module Spree
  module Calculator::Shipping
    module Fedex
      class StandardOvernight < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.standard_overnight")
        end
      end
    end
  end
end
