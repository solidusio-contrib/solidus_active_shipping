require 'spree/testing_support/factories/order_factory'

FactoryGirl.define do
  # The order with line items factory was updated in 1.2 to take a stock
  # location as a transient attribute. This brings that change so we can
  # specify the stock location which is used for the origin address for packages
  # and can be removed when we no longer want to support Solidus 1.0 and 1.1.
  factory :order_with_line_items_and_stock_location, parent: :order do
    bill_address
    ship_address

    transient do
      line_items_count 1
      line_items_attributes { [{}] * line_items_count }
      shipment_cost 100
      shipping_method nil
      stock_location { create(:stock_location) }
    end

    after(:create) do |order, evaluator|
      evaluator.stock_location # must evaluate before creating line items

      evaluator.line_items_attributes.each do |attributes|
        attributes = {
          order: order,
          price: evaluator.line_items_price
        }.merge(attributes)

        create(:line_item, attributes)
      end
      order.line_items.reload

      create(
        :shipment,
        order: order,
        cost: evaluator.shipment_cost,
        shipping_method: evaluator.shipping_method,
        stock_location: evaluator.stock_location
      )

      order.shipments.reload

      order.update!
    end
  end
end
