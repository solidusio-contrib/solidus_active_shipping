shared_context 'checkout setup' do
  let!(:store) { create(:store) }
  let!(:stock_location) { create :stock_location,
    address1: '1600 Pennsylvania Ave NW',
    city: 'Washington',
    zipcode: '20500',
    state: create(:state_with_autodiscover, state_code: 'DC')
  }
  let!(:shipping_method) { create(:shipping_method, calculator: Spree::Calculator::Shipping::Ups::NextDayAir.new) }
  let!(:payment_method) { create(:check_payment_method) }
  let!(:zone) { create(:zone) }
  let!(:mug) { create(:product, name: 'RoR Mug', weight: 2) }
end
