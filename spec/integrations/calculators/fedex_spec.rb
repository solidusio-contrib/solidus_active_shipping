require 'spec_helper'

describe 'FedEx calculators' do
  include_context 'FedEx setup'
  include_context 'package setup'

  subject { described_class.new.compute_package(package) }

  context 'with Canadian origin address' do
    include_context 'Canada stock location'

    describe Spree::Calculator::Shipping::Fedex::Ground do
      it { is_expected.to eq(29.10) }
    end

    describe Spree::Calculator::Shipping::Fedex::InternationalEconomy do
      it { is_expected.to eq(71.54) }
    end

    describe Spree::Calculator::Shipping::Fedex::InternationalFirst do
      it { is_expected.to eq(168.43) }
    end

    describe Spree::Calculator::Shipping::Fedex::InternationalPriority do
      it { is_expected.to eq(105.19) }
    end
  end

  context 'with US origin address' do
    include_context 'US stock location'

    describe Spree::Calculator::Shipping::Fedex::FirstOvernight do
      it { is_expected.to eq(106.13) }
    end

    describe Spree::Calculator::Shipping::Fedex::PriorityOvernight do
      it { is_expected.to eq(40.95) }
    end

    describe Spree::Calculator::Shipping::Fedex::StandardOvernight do
      it { is_expected.to eq(75.96) }
    end

    describe Spree::Calculator::Shipping::Fedex::TwoDay do
      it { is_expected.to eq(27.42) }
    end

    describe Spree::Calculator::Shipping::Fedex::ExpressSaver do
      it { is_expected.to eq(25.95) }
    end

    describe Spree::Calculator::Shipping::Fedex::GroundHomeDelivery do
      it { is_expected.to eq(14.10) }
    end
  end
end
