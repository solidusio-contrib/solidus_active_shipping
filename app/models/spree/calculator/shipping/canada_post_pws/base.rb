require_dependency 'spree/calculator'

module Spree
  module Calculator::Shipping
    module CanadaPostPws
      class Base < Spree::Calculator::Shipping::ActiveShipping::Base
        def carrier
          canada_post_pws_options = {
            # API keys have the following format first_part:second_part
            # The first part is the username
            # The second part is the password
            #
            # Referred as API key in ActiveShipping but it's actually called userid
            api_key:         Spree::ActiveShipping::Config[:canada_post_pws_userid],
            # Referred as secret in ActiveShipping but it's actually called password
            secret:          Spree::ActiveShipping::Config[:canada_post_pws_password],
            endpoint:        Spree::ActiveShipping::Config[:test_mode] ?
                               'https://ct.soa-gw.canadapost.ca/' : nil,
            customer_number: Spree::ActiveShipping::Config[:canada_post_pws_customer_number],
            contract_number: Spree::ActiveShipping::Config[:canada_post_pws_contract_number]
          }

          ::ActiveShipping::CanadaPostPWS.new(canada_post_pws_options)
        end
      end
    end
  end
end
