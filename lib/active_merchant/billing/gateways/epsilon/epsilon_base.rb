module ActiveMerchant #:nodoc:
  module Billing #:nodoc
    class EpsilonBaseGateway < Gateway
      self.abstract_class = true

      cattr_accessor :contract_code, :proxy_address, :proxy_port

      self.test_url            = 'https://beta.epsilon.jp/cgi-bin/order/'
      self.live_url            = 'https://secure.epsilon.jp/cgi-bin/order/'
      self.supported_countries = ['JP']
      self.default_currency    = 'JPY'
      self.homepage_url        = 'http://www.example.net/'
      self.display_name        = 'New Gateway'
    end
  end
end
