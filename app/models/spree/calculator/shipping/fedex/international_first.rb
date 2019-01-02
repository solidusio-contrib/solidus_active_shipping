require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module Fedex
      class InternationalFirst < Spree::Calculator::Shipping::Fedex::Base
        def self.description
          I18n.t('spree.fedex.intl_first')
        end
      end
    end
  end
end
