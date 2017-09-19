shared_context 'FedEx setup' do
  before do
    WebMock.allow_net_connect!
    Spree::ActiveShipping::Config[:fedex_login] = '118723830'
    Spree::ActiveShipping::Config[:fedex_password] = 'UGu5boYODXZ2GEDyUN4Xi1v8E'
    Spree::ActiveShipping::Config[:fedex_account] = '510087143'
    Spree::ActiveShipping::Config[:fedex_key] = 'xkBPuqiFmGrOU4jL'
    Spree::ActiveShipping::Config[:test_mode] = true
  end

  after do
    WebMock.disable_net_connect!
  end
end
