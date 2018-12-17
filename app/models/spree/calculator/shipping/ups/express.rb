module Spree
  module Calculator::Shipping
    module Ups
      class Express < Spree::Calculator::Shipping::Ups::Base
        def self.description
          I18n.t('spree.ups.express')
        end
      end
    end
  end
end
