shared_context 'Canada Post PWS setup' do
  before do
    WebMock.allow_net_connect!
    config = Spree::ActiveShippingConfiguration.new
    config.canada_post_pws_userid = '6e93d53968881714'
    config.canada_post_pws_password = '0bfa9fcb9853d1f51ee57a'
    config.canada_post_pws_customer_number = '2004381'
    config.canada_post_pws_contract_number = '42708517'
    config.test_mode = true
  end

  after do
    WebMock.disable_net_connect!
  end
end
