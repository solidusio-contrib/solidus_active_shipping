shared_context 'FedEx setup' do
  before do
    WebMock.allow_net_connect!
    config = Spree::ActiveShippingConfiguration.new
    config.fedex_login = '118723830'
    config.fedex_password = 'UGu5boYODXZ2GEDyUN4Xi1v8E'
    config.fedex_account = '510087143'
    config.fedex_key = 'xkBPuqiFmGrOU4jL'
    config.test_mode = true
  end

  after do
    WebMock.disable_net_connect!
  end
end
