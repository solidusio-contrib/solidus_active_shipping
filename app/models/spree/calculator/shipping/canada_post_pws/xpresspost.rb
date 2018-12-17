require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module CanadaPostPws
      class Xpresspost < Spree::Calculator::Shipping::CanadaPostPws::Base
        def self.description
          I18n.t('spree.canada_post_pws.xpresspost')
        end
      end
    end
  end
end
