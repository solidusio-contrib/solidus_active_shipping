require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module CanadaPostPws
      class PriorityWorldwideParcelUsa < Spree::Calculator::Shipping::CanadaPostPws::Base
        def self.description
          I18n.t('canada_post_pws.priority_worldwide_parcel_usa')
        end
      end
    end
  end
end
