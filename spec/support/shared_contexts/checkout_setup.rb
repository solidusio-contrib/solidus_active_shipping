shared_context 'checkout setup' do
  let!(:store) { create(:store) }
  let!(:shipping_method) do
    create(
      :shipping_method,
      calculator: Spree::Calculator::Shipping::Ups::NextDayAir.new
    )
  end
  let!(:payment_method) { create(:check_payment_method) }
  let!(:zone) { create(:zone) }
  let!(:mug) { create(:product, name: 'RoR Mug', weight: 2) }
end
