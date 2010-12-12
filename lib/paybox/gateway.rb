module Paybox
  module Gateway
    extend ActiveSupport::Concern

    included do
      include HTTParty
      base_uri 'https://preprod-ppps.paybox.com'
      PROCESS_PATH = '/PPPS.php'
    end
  end
end
