module Spree
  module Calculator::Shipping
    module CanadaPost
      class Regular < Spree::Calculator::Shipping::CanadaPost::Base
        def self.description
          Spree.t("canada_post.regular")
        end
      end
    end
  end
end
