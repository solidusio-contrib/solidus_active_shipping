require 'spec_helper'

module ActiveShipping
  describe Spree::ShippingCalculator do

    def build_content_items(variant, quantity, order)
      quantity.times.map {|i| Spree::Stock::ContentItem.new(build_inventory_unit(variant, order)) }
    end

    def build_inventory_unit(variant, order)
      build(:inventory_unit, variant: variant, order: order)
    end

    let(:country) { build(:country, :iso => "CA") }
    let(:address) { build(:address, :country => country, :state_name => "Quebec", :city => "Montreal", :zipcode => "H2B", :state => nil) }
    let(:usa) { FactoryGirl.create(:country, :name => "USA", :iso => "US") }
    let(:state) { FactoryGirl.create(:state, country: usa, abbr: 'MD', name: 'Maryland')}
    let(:us_address) { FactoryGirl.create(:address, :country => usa, :state => state, :city => "Chevy Chase", :zipcode => "20815") }
    let(:ca_order) { build(:order, ship_address: address) }
    let(:us_order) { build(:order, ship_address: us_address) }
    let(:package1) { mock_model(Spree::ProductPackage, :length => 12, :width => 24, :height => 47, :weight => 36) }
    let(:package2) { mock_model(Spree::ProductPackage, :length => 6, :width => 6, :height => 51, :weight => 43) }
    let(:variant1) { build(:variant, :weight => 20.0) }
    let(:variant2) { build(:variant, :weight => 5.25) }
    let(:variant3) { build(:variant, :weight => 29.0) }
    let(:variant4) { build(:variant, :weight => 100.0) }
    let(:variant_zero_weight) { build(:variant, :weight => 0) }
    let(:variant_negative_weight) { build(:variant, :weight => -1.0) }
    let(:variant7) do
      build(
        :variant,
        :weight => 29.0,
        :product => build(
          :product,
          :product_packages => [package1, package2]
        )
      )
    end
    let(:variant8) do
      build(
        :variant,
        :weight => 5.25,
        :product => build(:product, :product_packages => [])
      )
    end
    let(:california) { FactoryGirl.create(:state, country: usa, abbr: 'CA', name: 'California') }
    let(:stock_location) { FactoryGirl.create(:stock_location, :address1 => '1313 S Harbor Blvd', :address2 => '', :city => 'Anaheim', :state => california, :country => usa, :phone => '7147814000', :active => 1) }

    let(:package) { double(Spree::Stock::Package,
          order: ca_order,
          contents: [build_content_items(variant1, 10, ca_order),
                    build_content_items(variant2, 4, ca_order),
                    build_content_items(variant3, 1, ca_order)].flatten) }

    let(:small_package) { double(Spree::Stock::Package,
          order: ca_order,
          contents: [build_content_items(variant1, 1, ca_order),
                    build_content_items(variant2, 2, ca_order),
                    build_content_items(variant3, 1, ca_order)].flatten) }

    let(:too_heavy_package) do
      Spree::Stock::Package.extend ActiveModel::Naming
      mock_model(
        Spree::Stock::Package,
        order: ca_order,
        stock_location: stock_location,
        contents: [
          build_content_items(variant3, 2, ca_order),
          build_content_items(variant4, 2, ca_order)
        ].flatten
      )
    end

    let(:us_package) { double(Spree::Stock::Package,
          order: ca_order,
          contents: [build_content_items(variant1, 10, ca_order),
                    build_content_items(variant2, 4, ca_order),
                    build_content_items(variant3, 1, ca_order)].flatten) }

    let(:us_package_with_invalid_weights) { double(Spree::Stock::Package,
          order: us_order,
          contents: [build_content_items(variant_zero_weight, 1, us_order),
                    build_content_items(variant_negative_weight, 1, us_order)].flatten) }

    let(:package_with_packages) { double(Spree::Stock::Package,
          order: us_order,
          contents: [build_content_items(variant8, 4, us_order),
                    build_content_items(variant7, 2, us_order)].flatten) }

    let(:package_single_item) { double(Spree::Stock::Package,
          order: ca_order,
          contents: [build_content_items(variant1, 2, ca_order)].flatten) }

    let(:international_calculator) {  Spree::Calculator::Shipping::Usps::PriorityMailInternational.new }
    let(:domestic_calculator) {  Spree::Calculator::Shipping::Usps::PriorityMail.new }

    before(:each) do
      Rails.cache.clear
      Spree::ActiveShipping::Config.set(:units => "imperial")
      Spree::ActiveShipping::Config.set(:unit_multiplier => 16)
      Spree::ActiveShipping::Config.set(:default_weight => 1)
    end

    describe ".valid_weight_for_package?" do
      context "with a non nil max weight" do
        it "should return true if the max_weight is equal to zero" do
          expect(domestic_calculator.send :valid_weight_for_package?, package, 0).to eq true
        end

        it "should return true if the package weight is equal to the supplied max_weight" do
          allow(package).to receive(:weight).and_return(1)
          expect(domestic_calculator.send :valid_weight_for_package?, package, 1).to eq true
        end

        it "should return true if the package weight is less than the supplied max_weight" do
          allow(package).to receive(:weight).and_return(1)
          expect(domestic_calculator.send :valid_weight_for_package?, package, 2).to eq true
        end

        it "should return false if the package weight is greater than the supplied max_weight" do
          allow(package).to receive(:weight).and_return(3)
          expect(domestic_calculator.send :valid_weight_for_package?, package, 2).to eq false
        end
      end

      context "with a nil max weight" do
        it "should return false if the max_weight is nil" do
          expect(domestic_calculator.send :valid_weight_for_package?, package, nil).to eq false
        end
      end
    end

    describe ".country_weight_error?" do
      context "with a package that is too heavy" do
        it "should raise a Spree::ShippingError" do
          allow(domestic_calculator).to receive(:valid_weight_for_package?).and_return(false)
          expect{ domestic_calculator.send :country_weight_error?, package }.to raise_error(Spree::ShippingError)
        end
      end

      context "with a package within the weights limit" do
         it "should return false" do
          allow(domestic_calculator).to receive(:valid_weight_for_package?).and_return(true)
          expect(domestic_calculator.send :country_weight_error?, package).to be_nil
        end
      end
    end

    describe ".convert_package_to_weights_array" do
      it "should use the unit_multiplier from Spree::ActiveShipping::Config" do
        # Small package content is : 1 x Variant1, 1x Variant2, 1x Variant3
        weights = international_calculator.send :convert_package_to_weights_array, small_package
        active_shipping_weights = [variant1.weight, variant2.weight, variant2.weight, variant3.weight].map do |x|
            (x * Spree::ActiveShipping::Config[:unit_multiplier]).to_d
        end
        expect(weights).to match_array active_shipping_weights
      end

      context "with a package containing variants with no weight" do
        before do
          # It's not set globally, therefore we set a value before those tests
          Spree::ActiveShipping::Config.set(:max_weight_per_package => 30)
        end

        it "should use the default_weight from Spree::ActiveShipping" do
          default_weight = Spree::ActiveShipping::Config[:default_weight]
          weights = domestic_calculator.send :convert_package_to_weights_array, us_package_with_invalid_weights

          active_shipping_weights = [default_weight, default_weight].map do |x|
            (x * Spree::ActiveShipping::Config[:unit_multiplier]).to_d
          end

          expect(weights).to match_array active_shipping_weights
        end
      end

      context "with a package containing variants with individual item weight less than or equal to the maximum per package weight" do
        before do
          # It's not set globally, therefore we set a value before those tests
          Spree::ActiveShipping::Config.set(:max_weight_per_package => 100)
        end

        it "should return an array containing the expected weight values" do
          weights = international_calculator.send :convert_package_to_weights_array, small_package
          active_shipping_weights = [variant1.weight, variant2.weight, variant2.weight, variant3.weight].map do |x|
            (x * Spree::ActiveShipping::Config[:unit_multiplier]).to_d
          end
          expect(weights).to match_array active_shipping_weights
        end
      end

      context "with a package containing variants with an individual item weight higher than the maximum per package weight" do
        before do
          # It's not set globally, therefore we set a value before those tests
          Spree::ActiveShipping::Config.set(:max_weight_per_package => 1)
        end

        it "should raise a Spree::ShippingError" do
          expect{domestic_calculator.send :convert_package_to_weights_array, small_package }.to raise_error(Spree::ShippingError)
        end
      end

      context "with a package containing variants where total weight (item weight * quantity) is higher than the maximum per package weight" do
        before do
          # It's not set globally, therefore we set a value before those tests
          Spree::ActiveShipping::Config[:unit_multiplier] = 1
          Spree::ActiveShipping::Config.set(:max_weight_per_package => 30)
        end

        # Individual weight is 20 so with a max weight of 30 per package, we can ship one but not two
        # in the same package

        # TO DO Compare Array instead with repeating records
        it "should return an array with a value for each individual item (1 product x 2 counts as two separate items)" do
          weights = domestic_calculator.send :convert_package_to_weights_array, package_single_item
          active_shipping_weights = [variant1.weight, variant1.weight].map do |x|
            (x * Spree::ActiveShipping::Config[:unit_multiplier]).to_d
          end
          expect(weights).to match_array active_shipping_weights
        end
      end

      context "with a package containing variants where total weight (item weight * quantity) is less than or equal to the maximum per package weight" do
        before do
          # It's not set globally, therefore we set a value before those tests
          Spree::ActiveShipping::Config[:unit_multiplier] = 1
          Spree::ActiveShipping::Config.set(:max_weight_per_package => 30)
        end

        # Packages are made of ContentItem who does not track quantity (hardcoded value of 1) so
        # this means that if you have a LineItem with a quantity of 2, you will have 2 ContentItem
        # instead of one ContentItem with a quantity of 2, so this feature does not work at the moment

        # TO DO Compare Array instead with repeating records
        it "should return an array with a value for each individual item (1 product x 2 counts as two separate items)" do
          weights = domestic_calculator.send :convert_package_to_weights_array, package_single_item
          active_shipping_weights = [variant1.weight, variant1.weight].map do |x|
            (x * Spree::ActiveShipping::Config[:unit_multiplier]).to_d
          end
          expect(weights).to match_array active_shipping_weights
        end
      end
    end

    describe ".get_max_weight" do
      context "when .max_weight_for_country is returning a nil value" do
        # This can happen when individual calculators override the method and fails
        # for various reason (like USPS / Priority mail international will return nil when
        # using a country that is not in the WEIGHT_LIMIT array and .get_max_weight will crash
        # and return undefined method `>' for nil:NilClass
        it "should return an error" do
          allow(domestic_calculator).to receive(:max_weight_for_country).and_return(nil)
          expect{domestic_calculator.send :get_max_weight, package}.to raise_error(NoMethodError, "undefined method `>' for nil:NilClass")
        end
      end
    end

    describe ".fetch_best_state_from_address" do
      let(:qc) { FactoryGirl.create(:state, country: country, abbr: 'QC', name: 'Quebec (state_model)')}
      let(:state_and_state_name) { build(:address, :country => country, :state_name => "Quebec (state_name)", :city => "Montreal", :zipcode => "H2B", :state => qc) }

      subject { domestic_calculator.send :fetch_best_state_from_address, state_and_state_name }

      context "with an address having an associated state" do
        it "returns the abbr through the Spree::State model (address.state.abbr)" do         
           expect(subject).to eq "QC"
        end

        it "does not return the state_name from the Spree::Adress model (address.state_name)" do
          expect(subject).not_to eq "Quebec (state_name)"
        end
      end
    end

    describe "compute" do
      context "for international calculators" do
        it "should convert package contents to weights array for non-US countries (ex. Canada [limit = 66lbs])" do
          weights = international_calculator.send :convert_package_to_weights_array, package
          active_shipping_weights = [5.25, 5.25, 5.25, 5.25, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 29.0].map do |x|
            (x * Spree::ActiveShipping::Config[:unit_multiplier]).to_d
          end
          expect(weights).to match_array active_shipping_weights
        end

        it "should create array of packages" do
          packages = international_calculator.send :packages, package
          expect(packages.size).to eq(5)
          expect(packages.map{|package| package.weight.amount}).to eq([61.0, 60.0, 60.0, 40.0, 29.0].map{|x| x * Spree::ActiveShipping::Config[:unit_multiplier]})
          expect(packages.map{|package| package.weight.unit}.uniq).to eq([:ounces])
        end

        context "raise exception if max weight exceeded" do
          it "should get Spree::ShippingError" do
            allow(too_heavy_package).to receive(:weight) do
              too_heavy_package.contents.sum{ |item| item.variant.weight * item.quantity }
            end
            expect { international_calculator.compute(too_heavy_package) }.to raise_error(Spree::ShippingError)
          end
        end
      end

      context "for domestic calculators" do
        it "should not convert order line items to weights array for US" do
          weights = domestic_calculator.send :convert_package_to_weights_array, us_package
          expect(weights).to eq([5.25, 5.25, 5.25, 5.25, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 29.0].map{|x| x * Spree::ActiveShipping::Config[:unit_multiplier]})
        end

        it "should create array with one package for US" do
          packages = domestic_calculator.send :packages, us_package
          expect(packages.size).to eq(4)
          expect(packages.map{|package| package.weight.amount}).to eq([61.0, 60.0, 60.0, 69.0].map{|x| x * Spree::ActiveShipping::Config[:unit_multiplier]})
          expect(packages.map{|package| package.weight.unit}.uniq).to eq([:ounces])
        end
      end
    end

    describe "weight limits" do
      it "should be set for USPS calculators" do
        expect(international_calculator.send(:max_weight_for_country, country)).to eq(66.0 * Spree::ActiveShipping::Config[:unit_multiplier]) # Canada
        expect(domestic_calculator.send(:max_weight_for_country, country)).to eq(70.0 * Spree::ActiveShipping::Config[:unit_multiplier])
      end

      it "should respect the max weight per package" do
        Spree::ActiveShipping::Config.set(:max_weight_per_package => 30)
        weights = international_calculator.send :convert_package_to_weights_array, package
        expect(weights).to eq([5.25, 5.25, 5.25, 5.25, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 29.0].map{|x| x * Spree::ActiveShipping::Config[:unit_multiplier]})

        packages = international_calculator.send :packages, package
        expect(packages.size).to eq(12)
        expect(packages.map{|package| package.weight.amount}).to eq([21.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 29.0].map{|x| x * Spree::ActiveShipping::Config[:unit_multiplier]})
        expect(packages.map{|package| package.weight.unit}.uniq).to eq([:ounces])
      end
    end

    describe "validation of line item weight" do
      it "should avoid zero weight or negative weight" do
        weights = domestic_calculator.send :convert_package_to_weights_array, us_package_with_invalid_weights
        default_weight = Spree::ActiveShipping::Config[:default_weight] * Spree::ActiveShipping::Config[:unit_multiplier]
        expect(weights).to eq([default_weight, default_weight])
      end
    end

    describe "validation of default weight of zero" do
      it "should accept zero default weight" do
        Spree::ActiveShipping::Config.set(:default_weight => 0)
        weights = domestic_calculator.send :convert_package_to_weights_array, us_package_with_invalid_weights
        expect(weights).to eq([0, 0])
      end
    end

    describe "adds item packages" do
      it "should add item packages to weight calculation" do
        packages = domestic_calculator.send :packages, package_with_packages
        expect(packages.size).to eq(6)
        expect(packages.map{|package| package.weight.amount}).to eq([50, 29, 36, 43, 36, 43].map{|x| x * Spree::ActiveShipping::Config[:unit_multiplier]})
        expect(packages.map{|package| package.weight.unit}.uniq).to eq([:ounces])
      end
    end
  end
end
