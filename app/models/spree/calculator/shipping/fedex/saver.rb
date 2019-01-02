module Spree
  module Calculator::Shipping
    module Fedex
      class Saver < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          I18n.t('spree.fedex.saver')
        end
      end
    end
  end
end
