module Spree
  module Calculator::Shipping
    module Fedex
      class Saver < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          Spree.t("fedex.saver")
        end
      end
    end
  end
end
