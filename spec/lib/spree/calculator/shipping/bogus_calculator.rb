require 'spec_helper'

module Spree
  module Calculator::Shipping
    module ActiveShipping
      class BogusCalculator < Spree::Calculator::Shipping::ActiveShipping::Base
        def carrier
          @carrier ||= Spree::ActiveShipping::BogusCarrier.new
        end

        def self.description
          "Bogus Calculator"
        end
      end
    end
  end
end