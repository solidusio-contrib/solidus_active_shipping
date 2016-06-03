require 'spec_helper'

describe Spree::PackageBuilder do
  include_context 'Canada stock location'
  include PackageHelper

  let(:shipping_calculator) do
    Spree::Calculator::Shipping::ActiveShipping::BogusCalculator.new
  end

  let(:package_builder) { Spree::PackageBuilder.new }

  before do
    # We disable the multiplier so it's simpler to test
    allow(package_builder).to receive(:multiplier).and_return(1)
  end

  it 'has a a unit_multiplier value' do
    expect(package_builder.multiplier).not_to be_nil
  end

  it 'has a a units value' do
    expect(package_builder.units).not_to be_nil
  end

  it 'has a a default_weight value' do
    expect(package_builder.default_weight).not_to be_nil
  end

  describe 'process' do
    include_context 'package setup'

    let(:max_weight) { 0 }

    subject { package_builder.process(package, max_weight) }

    it 'returns an array of ActiveShipping::Package' do
      expect(subject.map(&:class).uniq).to match_array([ActiveShipping::Package])
    end

    it 'uses the unit multiplier in the calculations' do
      allow(package_builder).to receive(:multiplier).and_return(2)
      expect(subject.sum(&:weight)).to eq (package.weight * 2)
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

      let(:package) do
        build(:stock_package,
              stock_location: stock_location,
              contents: [build_content_items(product_with_packages, 2, order),
                         build_content_items(product_with_packages, 1, order)].flatten)
      end

      context 'when there is non-zero max_weight' do
        context 'when the product_package weight exceeds the allowed max_weight' do
          let(:max_weight) { product_weight - 1 }

          it 'raise a Spree::Shipping error' do
            expect { subject }.to raise_error(Spree::ShippingError)
          end
        end

        context 'when the product_packages weight does not exceed the allowed max_weight' do
          let(:max_weight) { 1000 }

          it 'return a ActiveShipping::Package for each ProductPackage of each ContentItem' do
            # Each individual item in the Order as a 1-1 association with a ContentItem
            expected_size = package.contents.sum { |item| item.variant.product.product_packages.size }
            expect(subject.size).to eq expected_size
          end
        end
      end

      context 'when there is no max weight (0)' do
        it 'return a ActiveShipping::Package for each ProductPackage of each ContentItem' do
          # Each individual item in the Order as a 1-1 association with a ContentItem
          expected_size = package.contents.sum { |item| item.variant.product.product_packages.size }
          expect(subject.size).to eq expected_size
        end
      end
    end

    context 'with an order containing only products without any associated product_packages' do
      include_context 'package setup'

      context 'when there is non-zero max_weight' do
        context 'and their combined weight is lower than the max_weight' do
          let(:max_weight) { package.weight + 1 }

          it 'will combine items into the same package' do
            expect(subject.size).to eq 1
          end
        end

        context 'and their combined weight is higher than the max_weight' do
          let(:max_weight) { package.weight - 1 }

          it 'will split items into multiple packages' do
            expect(subject.size).to eq 2
          end
        end

        context 'and the weight of a single item is higher than the max_weight' do
          let(:max_weight) { variant_2.weight - 1 }
          it 'will raise an Spree::ShippingError' do
            expect { subject }.to raise_error(Spree::ShippingError)
          end
        end
      end

      context 'when there is no max_weight' do
        it 'will combine all items into the same package' do
          expect(subject.size).to eq 1
        end
      end
    end

    context 'with an order containing some products with product_packages and some products without' do
      let(:product_weight) { 20 }
      let(:product_package1) { FactoryGirl.create(:product_package, weight: product_weight) }
      let(:product_package2) { FactoryGirl.create(:product_package, weight: product_weight) }

      let(:product_no_packages) { FactoryGirl.create(:variant, weight: 5) }
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

      let(:package) do
        build(:stock_package,
              stock_location: stock_location,
              contents: [build_content_items(product_with_packages, 1, order),
                         build_content_items(product_no_packages, 1, order),
                         build_content_items(product_no_packages, 1, order)].flatten)
      end

      let(:max_weight) { 1000 }

      it 'products with product_packages will not be combined with product with no packages' do
        active_shipping_packages = subject
        # First package in the array is the "default package" who should
        # only include product_with_no_packages x2
        expect(active_shipping_packages[0].weight).to eq (product_no_packages.weight * 2)
      end
    end
  end
end
