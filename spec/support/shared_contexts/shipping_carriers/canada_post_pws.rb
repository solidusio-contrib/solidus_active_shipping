shared_context 'Canada Post PWS setup' do
  before do
    WebMock.allow_net_connect!
    Spree::ActiveShipping::Config[:canada_post_pws_userid] = '6e93d53968881714'
    Spree::ActiveShipping::Config[:canada_post_pws_password] = '0bfa9fcb9853d1f51ee57a'
    Spree::ActiveShipping::Config[:canada_post_pws_customer_number] = '2004381'
    Spree::ActiveShipping::Config[:canada_post_pws_contract_number] = '42708517'
    Spree::ActiveShipping::Config[:test_mode] = true
  end

  after do
    WebMock.disable_net_connect!
  end
end
