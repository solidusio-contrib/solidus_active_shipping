module Spree
  module Calculator::Shipping
    module Ups
      class Ground < Spree::Calculator::Shipping::Ups::Base
        def self.description
          Spree.t("ups.ground")
        end
      end
    end
  end
end
