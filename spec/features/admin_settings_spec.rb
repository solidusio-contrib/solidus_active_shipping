require 'spec_helper'

describe "admin settings", type: :feature do
  scenario "with a valid UPS confguration" do
    login_as_admin

    visit spree.edit_admin_active_shipping_settings_path

    fill_in 'UPS Login', with: 'solidus'
    fill_in 'UPS Password', with: 'password'
    fill_in 'UPS Key', with: 'ups-test-api-key'
    fill_in 'Shipper Number', with: 'A1B2C3D4E5F6G7H8'

    submit_and_reload

    expect(find_field('UPS Login').value).to eq 'solidus'
    expect(find_field('UPS Password').value).to eq 'password'
    expect(find_field('UPS Key').value).to eq 'ups-test-api-key'
    expect(find_field('Shipper Number').value).to eq 'A1B2C3D4E5F6G7H8'
  end

  scenario "with a valid FedEx configuration" do
    login_as_admin

    visit spree.edit_admin_active_shipping_settings_path

    fill_in 'Fedex Login', with: 'solidus'
    fill_in 'Fedex Password', with: 'password'
    fill_in 'Fedex Account', with: '1234567890'
    fill_in 'Fedex Key', with: 'abcdefghijk1234567890'

    submit_and_reload

    expect(find_field('Fedex Login').value).to eq 'solidus'
    expect(find_field('Fedex Password').value).to eq 'password'
    expect(find_field('Fedex Account').value).to eq '1234567890'
    expect(find_field('Fedex Key').value).to eq 'abcdefghijk1234567890'
  end

  scenario 'with a valid USPS configuration' do
    login_as_admin

    visit spree.edit_admin_active_shipping_settings_path

    fill_in 'USPS Login', with: 'solidus'

    submit_and_reload

    expect(find_field('USPS Login').value).to eq 'solidus'
  end

  scenario 'with a valid Canada Post configuration' do
    login_as_admin

    visit spree.edit_admin_active_shipping_settings_path

    fill_in 'Canada Post Login', with: 'solidus'

    submit_and_reload

    expect(find_field('Canada Post Login').value).to eq 'solidus'
  end

  scenario 'with a valid Store configuration' do
    login_as_admin

    visit spree.edit_admin_active_shipping_settings_path

    fill_in 'Units', with: 'metric'
    fill_in 'Unit Multiplier', with: 0.0283
    fill_in 'Default Weight', with: 16
    fill_in 'Handling Fee', with: 200
    fill_in 'Max Weight Per Package', with: 128.0
    check 'Test Mode'

    submit_and_reload

    expect(find_field('Units').value).to eq 'metric'
    expect(find_field('Unit Multiplier').value).to eq '0.0283'
    expect(find_field('Default Weight').value).to eq '16'
    expect(find_field('Handling Fee').value).to eq '200'
    expect(find_field('Max Weight Per Package').value).to eq '128'
    expect(find_field('Test Mode').checked?).to eq true
  end

  def submit_and_reload
    click_button 'Update'

    expect(page).to have_content('Successfully updated configuration')

    visit spree.edit_admin_active_shipping_settings_path
  end
end
