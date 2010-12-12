require 'paybox'

RSpec.configure do |config|
  FakeWeb.allow_net_connect = false

  config.before :all do
    FakeWeb.register_uri(
      :post,
      "https://preprod-ppps.paybox.com/PPPS.php",
      :body => File.read(File.join(File.dirname(__FILE__), 'fixtures', 'PPPS.php'))
    )
  end
end
