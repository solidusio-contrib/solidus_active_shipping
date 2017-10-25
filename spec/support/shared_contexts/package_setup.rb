shared_context 'US package setup' do
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
  let(:variant_1) { FactoryBot.create(:variant, weight: 1) }
  let(:variant_2) { FactoryBot.create(:variant, weight: 2) }
  let(:order) do
    FactoryBot.create(
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

shared_context 'Canada package setup' do
  let(:destination) { create :address,
                      firstname: 'John',
                      lastname: 'Doe',
                      company: 'Company',
                      address1: '10 Harvey Street',
                      city: 'Alma',
                      state: create(:state_with_autodiscover, country_iso: 'CA', state_code: 'QC'),
                      zipcode: 'G8B1N5',
                      phone: "(555) 555-5555"
  }
  let(:variant_1) { FactoryBot.create(:variant, weight: 1) }
  let(:variant_2) { FactoryBot.create(:variant, weight: 2) }
  let(:order) do
    FactoryBot.create(
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
shared_context 'France package setup' do
  let(:destination) { create :address,
                      firstname: 'John',
                      lastname: 'Doe',
                      company: 'Company',
                      address1: '3960 Lexington Rd',
                      city: 'Paris',
                      state: create(:state_with_autodiscover, country_iso: 'FR', state_code: 'KY'),
                      zipcode: '40361',
                      phone: "(555) 555-5555"
  }

  let(:variant_1) { FactoryBot.create(:variant, weight: 1) }
  let(:variant_2) { FactoryBot.create(:variant, weight: 2) }
  let(:order) do
    FactoryBot.create(
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
