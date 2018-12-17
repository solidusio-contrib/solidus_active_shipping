require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module CanadaPostPws
      class ExpeditedUsa < Spree::Calculator::Shipping::CanadaPostPws::Base
        def self.description
          I18n.t('spree.canada_post_pws.expedited_usa')
        end
      end
    end
  end
end
