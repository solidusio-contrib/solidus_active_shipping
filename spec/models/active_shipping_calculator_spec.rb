require 'spec_helper'

describe Spree::Calculator::Shipping do
  # NOTE: All specs will use the bogus calculator
  # (no login information needed)

  let(:address) { FactoryBot.create(:address) }
  let(:variant_1) { FactoryBot.create(:variant, weight: 1) }
  let(:variant_2) { FactoryBot.create(:variant, weight: 2) }
  let!(:order) do
    FactoryBot.create(:order_with_line_items, ship_address: address, line_items_count: 2,
                                               line_items_attributes: [{ quantity: 2, variant: variant_1 }, { quantity: 2, variant: variant_2 }])
  end

  let(:calculator) { Spree::Calculator::Shipping::ActiveShipping::BogusCalculator.new }
  let(:package) { order.shipments.first.to_package }

  before(:each) do
    order.create_proposed_shipments
    Spree::ActiveShipping::Config.set(units: 'imperial')
    Spree::ActiveShipping::Config.set(unit_multiplier: 1)
    Spree::ActiveShipping::Config.set(handling_fee: 0)
  end

  describe 'available' do
    context 'when rates are available' do
      it 'should return true' do
        expect(calculator.available?(package)).to eq true
      end

      it 'should use zero as a valid weight for service' do
        allow(calculator.carrier).to receive(:max_weight_for_country).and_return(0)
        expect(calculator.available?(package)).to eq true
      end
    end

    context 'when rates are not available' do
      let(:invalid_response) do
        ::ActiveShipping::RateResponse.new(true, 'success!', {}, rates: [], xml: '')
      end

      before do
        allow(calculator.carrier).to receive(:find_rates).and_return(invalid_response)
      end

      it 'should return false' do
        expect(calculator.available?(package)).to eq false
      end
    end

    context 'when there is an error retrieving the rates' do
      before do
        allow(calculator.carrier).to receive(:find_rates).and_raise(::ActiveShipping::ResponseError)
      end

      it 'should return false' do
        expect(calculator.available?(package)).to eq false
      end
    end
  end

  describe 'available?' do
    # regression test for #164 and #171
    it 'should not return rates if the weight requirements for the destination country are not met' do
      # if max_weight_for_country is nil -> the carrier does not ship to that country
      # if max_weight_for_country is 0 -> the carrier does not have weight restrictions to that country
      allow(calculator).to receive(:max_weight_for_country).and_return(nil)
      expect(calculator).to receive(:is_package_shippable?).and_raise(Spree::ShippingError)
      expect(calculator.available?(package)).to eq false
    end
  end

  describe 'compute' do
    subject { calculator.compute(package) }

    context 'when the cache is warm' do
      it 'should check the cache first before finding rates' do
        # Since the cache is cleared between the tests, cache.fetch will return a miss,
        # but by passing a block { Hash.new }, the return value of the block will be
        # written under the given cache key so we simulate a warm cache
        Rails.cache.fetch(calculator.send(:cache_key, package)) { Hash.new }
        expect(calculator.carrier).not_to receive(:find_rates)
        subject
      end
    end

    context 'when the cache is empty' do
      before do
        # We're stubbing the carrier method because we
        # need to check that a specific instance of carrier
        # is receiving or not the function call (otherwise test will
        # pass but only because carrier we're watching and the carrier
        # used by the calculator are different)
        allow(calculator.carrier).to receive(:find_rates).and_call_original
      end

      it 'should call .find_rates' do
        expect(calculator.carrier).to receive(:find_rates)
        subject
      end
    end

    context 'with valid response' do
      it "should return rate based on calculator's service_name" do
        expect(subject).to eq 9.99
      end

      it 'should include handling_fee when configured' do
        Spree::ActiveShipping::Config.set(handling_fee: 100)
        expect(subject).to eq 10.99
      end

      it 'should return nil if service_name is not found in rate_hash' do
        allow(calculator.class).to receive(:description) { 'invalid service_name' }
        expect(subject).to be_nil
      end
    end

    context 'with invalid response' do
      before do
        allow(calculator.carrier).to receive(:find_rates).and_raise(::ActiveShipping::ResponseError)
      end

      it 'should raise a Spree::ShippingError' do
        expect { subject }.to raise_exception(Spree::ShippingError)
      end
    end
  end

  describe 'service_name' do
    it 'should return description when not defined' do
      expect(calculator.class.service_name).to eq calculator.description
    end
  end

  # We make an exception and tests this the private method because max_weight values
  # are difficult to tests conclusively through the
  describe 'get_max_weight' do
    include_context 'US stock location'
    include_context 'US package setup'

    context 'when the max_weight from the calculator is non-zero and max_weight_per_package is zero' do
      before do
        allow(calculator).to receive(:max_weight_for_country).and_return(1)
        allow(calculator).to receive(:max_weight_per_package).and_return(0)
      end

      it 'uses the max_weight_for_country as a max_weight' do
        expect(calculator.send(:get_max_weight, package)).to eq calculator.send(:max_weight_for_country)
      end
    end

    context 'when the max_weight from the calculator is zero and max_weight_per_package is non-zero' do
      before do
        allow(calculator).to receive(:max_weight_for_country).and_return(0)
        allow(calculator).to receive(:max_weight_per_package).and_return(1)
      end

      it 'uses the max_weight_per_package as a max_weight' do
        expect(calculator.send(:get_max_weight, package)).to eq calculator.send(:max_weight_per_package)
      end
    end

    context 'when the max_weight from the calculator is non-zero and max_weight_per_package is non-zero' do
      before do
        allow(calculator).to receive(:max_weight_per_package).and_return(SecureRandom.random_number(19) + 1)
        allow(calculator).to receive(:max_weight_for_country).and_return(SecureRandom.random_number(19) + 1)
      end

      it 'uses the lesser one of the two values' do
        min = [calculator.send(:max_weight_for_country), calculator.send(:max_weight_per_package)].min
        expect(calculator.send(:get_max_weight, package)).to eq min
      end
    end

    context 'when the max_weight is zero and max_weight_per_package is zero' do
      it 'uses 0 as a max_eight' do
        expect(calculator.send(:get_max_weight, package)).to be_zero
      end
    end
  end
end
