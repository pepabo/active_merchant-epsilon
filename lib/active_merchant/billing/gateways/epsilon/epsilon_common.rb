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

      def authorize(money, payment, options = {})
        raise ActiveMerchant::Epsilon::InvalidActionError
      end

      def capture(money, authorization, options = {})
        raise ActiveMerchant::Epsilon::InvalidActionError
      end

      def refund(money, authorization, options = {})
        raise ActiveMerchant::Epsilon::InvalidActionError
      end

      private

      def authorization_from(response)
        {}
      end

      def commit(action, params)
        url = (test? ? test_url : live_url)

        response = parse(ssl_post(url + path(action), post_data(params)))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          test: test?
        )
      end

      def message_from(response)
        response[:message]
      end

      def post_data(parameters = {})
        parameters.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
      end

      def success_from(response)
        response[:success]
      end

      def uri_decode(string)
        URI.decode(string).encode(Encoding::UTF_8, Encoding::CP932)
      end
    end
  end
end
