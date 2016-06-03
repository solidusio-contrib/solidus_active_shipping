require 'spec_helper'

describe Spree::PackageBuilder do
  include PackageHelper

  let(:address) { FactoryGirl.create(:address) }
  let(:stock_location) { FactoryGirl.create(:stock_location) }
  let(:order) { build(:order, ship_address: address) }

  let(:shipping_calculator) { Spree::Calculator::Shipping::ActiveShipping::BogusCalculator.new }
  let(:package_builder) { Spree::PackageBuilder.new(shipping_calculator) }

  it 'has a a unit_multiplier value' do
    expect(package_builder.multiplier).not_to be_nil
  end

  it 'has a a units value' do
    expect(package_builder.units).not_to be_nil
  end

  it 'has a a default_weight value' do
    expect(package_builder.default_weight).not_to be_nil
  end

  it 'has a a max_weight_per_package value' do
    expect(package_builder.max_weight_per_package).not_to be_nil
  end

  context 'with an order containing only products with associated product_packages' do
    let(:product_weight) { 20 }
    let(:product_package1) { FactoryGirl.create(:product_package, weight: product_weight) }
    let(:product_package2) { FactoryGirl.create(:product_package, weight: product_weight) }
    let(:product_with_packages) do
      build(
        :variant,
        weight: product_weight,
        product: build(
          :product,
          product_packages: [product_package1, product_package2]
        )
      )
    end

    let(:solidus_package) do
      build(:stock_package,
            stock_location: stock_location,
            contents: [build_content_items(product_with_packages, 2, order),
                       build_content_items(product_with_packages, 1, order)].flatten)
    end

    describe 'process' do
      subject { package_builder.process(solidus_package) }

      it 'returns an array of ActiveShipping::Package' do
        expect(subject.map(&:class).uniq).to match_array([ActiveShipping::Package])
      end

      context 'when there is non-zero max_weight' do
        context 'when the product_package weight exceeds the allowed max_weight' do
          before do
            allow(package_builder).to receive(:max_weight_per_package).and_return(0)
            allow(shipping_calculator).to receive(:max_weight_for_country).and_return(1)
          end

          it 'raise a Spree::Shipping error' do
            expect { subject }.to raise_error(Spree::ShippingError)
          end
        end

        context 'when the product_packages weight does not exceed the allowed max_weight' do
          before do
            allow(shipping_calculator).to receive(:max_weight_for_country).and_return(product_weight + 1000)
          end

          it 'return a ActiveShipping::Package for each ProductPackage of each ContentItem' do
            # Each individual item in the Order as a 1-1 association with a ContentItem
            expected_size = solidus_package.contents.sum { |item| item.variant.product.product_packages.size }
            expect(subject.size).to eq expected_size
          end
        end
      end

      # We make an exception and tests this the private method because max_weight values
      # are difficult to tests conclusively through the
      context 'when the max_weight from the calculator is non-zero and max_weight_per_package is zero' do
        before do
          allow(shipping_calculator).to receive(:max_weight_for_country).and_return(1)
          allow(package_builder).to receive(:max_weight_per_package).and_return(0)
        end

        it 'uses the max_weight_for_country as a max_weight' do
          expect(package_builder.send(:get_max_weight, solidus_package)).to eq shipping_calculator.send(:max_weight_for_country)
        end
      end

      context 'when the max_weight from the calculator is zero and max_weight_per_package is non-zero' do
        before do
          allow(shipping_calculator).to receive(:max_weight_for_country).and_return(0)
          allow(package_builder).to receive(:max_weight_per_package).and_return(1)
        end

        it 'uses the max_weight_per_package as a max_weight' do
          expect(package_builder.send(:get_max_weight, solidus_package)).to eq package_builder.max_weight_per_package
        end
      end

      context 'when the max_weight from the calculator is non-zero and max_weight_per_package is non-zero' do
        before do
          allow(package_builder).to receive(:max_weight_per_package).and_return(SecureRandom.random_number(19) + 1)
          allow(shipping_calculator).to receive(:max_weight_for_country).and_return(SecureRandom.random_number(19) + 1)
        end

        it 'uses the lesser one of the two values' do
          min = [shipping_calculator.send(:max_weight_for_country), package_builder.max_weight_per_package].min
          expect(package_builder.send(:get_max_weight, solidus_package)).to eq min
        end
      end

      context 'when the max_weight is zero and max_weight_per_package is zero' do
        it 'return a ActiveShipping::Package for each ProductPackage of each ContentItem', :focus do
          expected_size = solidus_package.contents.sum { |item| item.variant.product.product_packages.size }
          expect(subject.size).to eq expected_size
        end
      end
    end
  end

  context 'with an order containing only products without any associated product_packages' do
    let(:variant_1) { FactoryGirl.create(:variant, weight: 5) }
    let(:variant_2) { FactoryGirl.create(:variant, weight: 17) }
    let!(:stock_location) { FactoryGirl.create(:stock_location) }
    let!(:order) do
      FactoryGirl.create(:order_with_line_items, ship_address: address, line_items_count: 2,
                       line_items_attributes: [{ quantity: 2, variant: variant_1}, { quantity: 2, variant: variant_2 }] )
    end

    pending("to implement")
  end

  context 'with an order containing some products with product_packages and some products without' do
     pending("to implement")
  end
end
