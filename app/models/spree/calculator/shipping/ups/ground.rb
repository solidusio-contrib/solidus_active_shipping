module Spree
  module Calculator::Shipping
    module Ups
      class Ground < Spree::Calculator::Shipping::Ups::Base
        def self.description
          I18n.t('spree.ups.ground')
        end
      end
    end
  end
end
