shared_context 'Canada stock location' do
  let(:ontario) do
    create(:state_with_autodiscover, country_iso: 'CA', state_code: 'ON')
  end
  let!(:stock_location) do
    create(
      :stock_location,
      name: 'Canda Warehouse',
      address1: '123 Test Street',
      city: 'Ottawa',
      zipcode: 'K1P1J1',
      state: ontario,
      country: ontario.country
    )
  end
end

shared_context 'US stock location' do
  let!(:stock_location) do
    create :stock_location,
      address1: '1600 Pennsylvania Ave NW',
      city: 'Washington',
      zipcode: '20500',
      state: create(:state_with_autodiscover, state_code: 'DC')
  end
end
