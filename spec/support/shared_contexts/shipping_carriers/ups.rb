shared_context 'UPS setup' do
  before do
    WebMock.allow_net_connect!
    Spree::ActiveShipping::Config[:ups_login] = 'solidusdev'
    Spree::ActiveShipping::Config[:ups_password] = 'S0lidusdev'
    Spree::ActiveShipping::Config[:ups_key] = '9D0B1B1E0A6389A8'
    Spree::ActiveShipping::Config[:test_mode] = true
  end

  after do
    WebMock.disable_net_connect!
  end
end
