module Spree
  module Calculator::Shipping
    module CanadaPost
      class PriorityWorldwideIntl < Spree::Calculator::Shipping::CanadaPost::Base
        def self.description
          I18n.t('spree.canada_post.priority_worldwide_intl')
        end
      end
    end
  end
end

