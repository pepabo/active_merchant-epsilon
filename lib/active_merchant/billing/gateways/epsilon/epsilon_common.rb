module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EpsilonCommon
      def self.included(base)
        base.test_url            = 'https://beta.epsilon.jp/cgi-bin/order/'
        base.live_url            = 'https://secure.epsilon.jp/cgi-bin/order/'
        base.supported_countries = ['JP']
        base.default_currency    = 'JPY'
        base.homepage_url        = 'http://www.example.net/'
        base.display_name        = 'New Gateway'

        base.cattr_accessor :contract_code, :proxy_address, :proxy_port
      end

      def initialize(options = {})
        super
      end

      def purchase(amount, payment_method, detail = {})
        detail[:process_code] = 1
        detail[:mission_code] = Epsilon::MissionCode::PURCHASE

        params = billing_params(amount, payment_method, detail)

        commit('purchase', params)
      end
    end
  end
end
