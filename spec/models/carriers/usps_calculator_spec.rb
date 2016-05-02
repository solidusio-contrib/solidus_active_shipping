require 'spec_helper'

module ActiveShipping
  describe Spree::Calculator::Shipping::Usps do
    WebMock.disable_net_connect!

    let(:address) { FactoryGirl.create(:address) }
    let(:stock_location) { FactoryGirl.create(:stock_location) }
    let!(:order) do
      order = FactoryGirl.create(:order_with_line_items, :ship_address => address, :line_items_count => 2)
      order.line_items.first.tap do |line_item|
        line_item.quantity = 2
        line_item.variant.save
        line_item.variant.weight = 1
        line_item.variant.save
        line_item.save
        # product packages?
      end
      order.line_items.last.tap do |line_item|
        line_item.quantity = 2
        line_item.variant.save
        line_item.variant.weight = 2
        line_item.variant.save
        line_item.save
        # product packages?
      end
      order
    end

    let(:carrier) { ActiveShipping::USPS.new(:login => "FAKEFAKEFAKE") }
    let(:calculator) { Spree::Calculator::Shipping::Usps::ExpressMail.new }
    let(:response) { double('response', :rates => rates, :params => {}) }
    let(:package) { order.shipments.first.to_package }

    before(:each) do
      Spree::StockLocation.destroy_all
      stock_location
      order.create_proposed_shipments
      order.shipments.count.should == 1
      Spree::ActiveShipping::Config.set(:units => "imperial")
      Spree::ActiveShipping::Config.set(:unit_multiplier => 1)
      calculator.stub(:carrier).and_return(carrier)
      Rails.cache.clear
    end

    describe "package.order" do
      it{ expect(package.order).to eq(order) }
      it{ expect(package.order.ship_address).to eq(address) }
      it{ expect(package.order.ship_address.country.iso).to eq('US') }
      it{ expect(package.stock_location).to eq(stock_location) }
    end

    describe "compute" do
      it "should use the carrier supplied in the initializer" do
        stub_request(:get, /http:\/\/production.shippingapis.com\/ShippingAPI.dll.*/).
            to_return(:body => fixture(:normal_rates_request))
        calculator.compute(package).should == 14.1
      end

      context "with valid response" do
        let(:rates) do
          [ double('rate', :service_code => "3", :price => 999) ]
        end

        before do
          carrier.should_receive(:find_rates).and_return(response)
        end

        it "should return rate based on calculator's service_code" do
          calculator.class.should_receive(:service_code).and_return("dom:3")
          rate = calculator.compute(package)
          rate.should == 9.99
        end

        it "should include handling_fee when configured" do
          calculator.class.should_receive(:service_code).and_return("dom:3")
          Spree::ActiveShipping::Config.set(:handling_fee => 100)
          rate = calculator.compute(package)
          rate.should == 10.99
        end

        it "should return nil if service_code is not found in rate_hash" do
          calculator.class.should_receive(:service_code).and_return("empty_service_code")
          rate = calculator.compute(package)
          rate.should be_nil
        end
      end
    end

    describe "service_name" do
      it "should return description when not defined" do
        calculator.class.service_name.should == calculator.description
      end
    end
  end

end
