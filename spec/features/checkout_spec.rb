require 'spec_helper'

describe "Checkout", type: :feature do
  include_context 'checkout setup'
  include CheckoutHelper

  include_context 'UPS setup'

  context "with valid shipping address" do
    let!(:valid_address) { create :address,
      firstname: 'John',
      lastname: 'Doe',
      company: 'Company',
      address1: '4157 Lawnview Ave',
      city: 'Dallas',
      state: create(:state_with_autodiscover, state_code: 'TX'),
      zipcode: '75227',
      phone: "(555) 555-5555"
    }

    it "does not break the per-item shipping method calculator", js: true do
      add_to_cart(mug)

      click_button "Checkout"

      fill_in "order_email", with: "test@example.com"
      click_button "Continue"
      fill_in_address(valid_address)
      click_button "Save and Continue"

      # select default shipping
      click_button "Save and Continue"
      expect(page).to have_content("Shipping total: $68.81")
    end
  end
end
