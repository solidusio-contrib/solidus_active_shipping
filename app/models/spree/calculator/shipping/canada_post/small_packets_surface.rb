module Spree
  module Calculator::Shipping
    module CanadaPost
      class SmallPacketsSurface < Spree::Calculator::Shipping::CanadaPost::Base
        def self.description
          I18n.t('spree.canada_post.small_packets_surface')
        end
      end
    end
  end
end
