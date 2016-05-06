module CheckoutHelper
  def fill_in_address(address)
    fill_in "First Name", with: address.firstname
    fill_in "Last Name", with: address.lastname
    fill_in "Street Address", with: address.address1
    fill_in "City", with: address.city
    select address.country.name, from: "Country"
    select address.state.name, from: "order_bill_address_attributes_state_id" # until spree/address/_form.html.erb is fixed
    fill_in "Zip", with: address.zipcode
    fill_in "Phone", with: address.phone
  end
end
