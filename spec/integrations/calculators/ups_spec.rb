require 'spec_helper'

describe 'UPS calculators', :vcr do
  include_context 'UPS setup'
  include_context 'package setup'

  subject { described_class.new.compute_package(package) }

  context 'with Canadian origin address' do
    include_context 'Canada stock location'

    describe Spree::Calculator::Shipping::Ups::Express do
      it { is_expected.to eq(139.1) }
    end

    describe Spree::Calculator::Shipping::Ups::WorldwideExpedited  do
      it { is_expected.to eq(97.15) }
    end

    describe Spree::Calculator::Shipping::Ups::Saver do
      it { is_expected.to eq(132.25) }
    end

    describe Spree::Calculator::Shipping::Ups::Standard do
      it { is_expected.to eq(35.34) }
    end

    describe Spree::Calculator::Shipping::Ups::ThreeDaySelect do
      it { is_expected.to eq(89.7) }
    end
  end

  context 'with US origin address' do
    include_context 'US stock location'

    describe Spree::Calculator::Shipping::Ups::Ground do
      it { is_expected.to eq(14.2) }
    end

    describe Spree::Calculator::Shipping::Ups::NextDayAir do
      it { is_expected.to eq(79.47) }
    end

    describe Spree::Calculator::Shipping::Ups::NextDayAirEarlyAm do
      it { is_expected.to eq(110.29) }
    end

    describe Spree::Calculator::Shipping::Ups::NextDayAirSaver do
      it { is_expected.to eq(77.46) }
    end

    describe Spree::Calculator::Shipping::Ups::SecondDayAir do
      it { is_expected.to eq(27.97) }
    end
  end
end
