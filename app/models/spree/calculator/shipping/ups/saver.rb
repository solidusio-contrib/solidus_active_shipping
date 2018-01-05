module Spree
  module Calculator::Shipping
    module Ups
      class Saver < Spree::Calculator::Shipping::Ups::Base
        def self.description
          Spree.t("ups.saver")
        end
      end
    end
  end
end
