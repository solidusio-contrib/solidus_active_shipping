require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class Ground < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          I18n.t('spree.fedex.ground')
        end
      end
    end
  end
end
