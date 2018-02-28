module Spree
  module Calculator::Shipping
    module Ups
      class Standard < Spree::Calculator::Shipping::Ups::Base
        def self.description
          Spree.t("ups.standard")
        end
      end
    end
  end
end
