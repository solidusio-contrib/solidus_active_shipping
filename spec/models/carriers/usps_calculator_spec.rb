require 'spec_helper'

describe Spree::Calculator::Shipping::Usps do
  let(:address) { FactoryGirl.create(:address) }
  let(:variant_1) { FactoryGirl.create(:variant, weight: 1) }
  let(:variant_2) { FactoryGirl.create(:variant, weight: 2) }
  let!(:order) do
    FactoryGirl.create(:order_with_line_items, ship_address: address, line_items_count: 2,
                       line_items_attributes: [{ quantity: 2, variant: variant_1}, { quantity: 2, variant: variant_2 }] )
  end

  let(:carrier) { ActiveShipping::USPS.new(login: 'FAKEFAKEFAKE') }
  let(:calculator) { Spree::Calculator::Shipping::Usps::ExpressMail.new }
  let(:package) { order.shipments.first.to_package }

  before(:each) do
    order.create_proposed_shipments
    Spree::ActiveShipping::Config.set(units: 'imperial')
    Spree::ActiveShipping::Config.set(unit_multiplier: 1)
    Spree::ActiveShipping::Config.set(handling_fee: 0)

    stub_request(:get, %r{http:\/\/production.shippingapis.com\/ShippingAPI.dll.*})
        .to_return(body: fixture(:normal_rates_request))

    # Since the response can be cached, we explicitly clear cache
    # so each test can be run from a clean slate
    Rails.cache.delete(calculator.send(:cache_key, package))
  end

  describe 'compute' do
    subject { calculator.compute(package) }

    it 'should use the carrier supplied in the initializer' do
      expect(subject).to eq 14.1
    end

    context 'with valid response' do
      it "should return rate based on calculator's service_code" do
        allow(calculator.class).to receive(:service_code) { 'dom:3' }
        expect(subject).to eq 14.1
      end

      it 'should include handling_fee when configured' do
        Spree::ActiveShipping::Config.set(handling_fee: 100)
        allow(calculator.class).to receive(:service_code) { 'dom:3' }
        expect(subject).to eq 15.1
      end

      it 'should return nil if service_code is not found in rate_hash' do
        allow(calculator.class).to receive(:service_code) { 'invalid service_code' }
        expect(subject).to be_nil
      end
    end

    context 'with invalid response' do
      before do
        allow(calculator).to receive(:carrier).and_return(carrier)
        allow(carrier).to receive(:find_rates).and_raise(::ActiveShipping::ResponseError)
      end

      it 'should raise a Spree::ShippingError' do
        expect{ subject }.to raise_exception(Spree::ShippingError)
      end
    end
  end

  describe 'service_name' do
    it 'should return description when not defined' do
      expect(calculator.class.service_name).to eq calculator.description
    end
  end
end
