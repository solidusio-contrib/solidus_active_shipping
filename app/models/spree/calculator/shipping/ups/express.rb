module Spree
  module Calculator::Shipping
    module Ups
      class Express < Spree::Calculator::Shipping::Ups::Base
        def self.description
          Spree.t("ups.express")
        end
      end
    end
  end
end
