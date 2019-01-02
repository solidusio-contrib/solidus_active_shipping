require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module CanadaPostPws
      class PriorityWorldwideParcel < Spree::Calculator::Shipping::CanadaPostPws::Base
        def self.description
          I18n.t('spree.canada_post_pws.priority_worldwide_parcel')
        end
      end
    end
  end
end
