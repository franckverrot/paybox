module Paybox
  module Gateway
    extend ActiveSupport::Concern

    included do
      include HTTParty
      base_uri 'https://preprod-ppps.paybox.com'
      PROCESS_PATH = '/PPPS.php'
    end

    private
    def _process hash
      self.class.post(PROCESS_PATH, :body => hash)
    end
  end
end
