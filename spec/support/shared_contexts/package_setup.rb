shared_context 'package setup' do
  let(:destination) { create :address,
                      firstname: 'John',
                      lastname: 'Doe',
                      company: 'Company',
                      address1: '5145 North California Avenue',
                      city: 'Chicago',
                      state: create(:state_with_autodiscover, state_code: 'IL'),
                      zipcode: '60601',
                      phone: "(555) 555-5555"
  }
  let(:variant_1) { FactoryGirl.create(:variant, weight: 1) }
  let(:variant_2) { FactoryGirl.create(:variant, weight: 2) }
  let(:order) do
    FactoryGirl.create(
      :order_with_line_items_and_stock_location,
      stock_location: stock_location,
      bill_address: destination,
      ship_address: destination,
      line_items_count: 2,
      line_items_attributes: [
        {
          quantity: 2,
          variant: variant_1
        },
        {
          quantity: 2,
          variant: variant_2
        }
      ]
    )
  end
  let(:package) { order.shipments.first.to_package }
end
