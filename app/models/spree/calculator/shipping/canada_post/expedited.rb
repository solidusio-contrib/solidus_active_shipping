module Spree
  module Calculator::Shipping
    module CanadaPost
      class Expedited < Spree::Calculator::Shipping::CanadaPost::Base
        def self.description
          Spree.t("canada_post.expedited")
        end
      end
   end
  end
end
