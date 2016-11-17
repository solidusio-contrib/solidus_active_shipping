require 'spec_helper'

describe 'Canada Post PWS calculators', :vcr do
  include_context 'Canada Post PWS setup'

  subject { described_class.new.compute_package(package) }

  context 'with Canadian origin address' do
    include_context 'Canada stock location'

    context 'and a Canadian destination address' do
      include_context 'Canada package setup'

      describe Spree::Calculator::Shipping::CanadaPostPws::Regular do
        it { is_expected.to eq(16.17) }
      end

      describe Spree::Calculator::Shipping::CanadaPostPws::Expedited do
        it { is_expected.to eq(16.17) }
      end

      describe Spree::Calculator::Shipping::CanadaPostPws::Xpresspost do
        it { is_expected.to eq(33.88) }
      end

      describe Spree::Calculator::Shipping::CanadaPostPws::Priority do
        it { is_expected.to eq(53.16) }
      end
    end

    context 'and a US destination address' do
      include_context 'US package setup'

      describe Spree::Calculator::Shipping::CanadaPostPws::ExpeditedUsa do
        it { is_expected.to eq(25.98) }
      end

      describe Spree::Calculator::Shipping::CanadaPostPws::PriorityWorldwideParcelUsa do
        it { is_expected.to eq(130.39) }
      end

      describe Spree::Calculator::Shipping::CanadaPostPws::XpresspostUsa do
        it { is_expected.to eq(42.92) }
      end
    end

    context 'and a international destination address' do
      include_context 'France package setup'

      describe Spree::Calculator::Shipping::CanadaPostPws::XpresspostInternational do
        it { is_expected.to eq 102.35 }
      end

      describe Spree::Calculator::Shipping::CanadaPostPws::PriorityWorldwideParcel do
        it { is_expected.to eq 177.17 }
      end
      describe Spree::Calculator::Shipping::CanadaPostPws::InternationalParcelSurface do
        it { is_expected.to eq 54.65 }
      end
    end
  end
end
