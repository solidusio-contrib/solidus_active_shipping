shared_context 'UPS setup' do
  before do
    login_as_admin
    visit spree.edit_admin_active_shipping_settings_path
    fill_in 'UPS Login', with: 'solidusdev'
    fill_in 'UPS Password', with: 'S0lidusdev'
    fill_in 'UPS Key', with: '9D0B1B1E0A6389A8'
    click_button 'Update'
  end
end
