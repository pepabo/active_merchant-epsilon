require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EpsilonCommon
      module ResponseXpath
        RESULT           = '//Epsilon_result/result[@result]/@result'
        TRANSACTION_CODE = '//Epsilon_result/result[@trans_code]/@trans_code'
        ERROR_CODE       = '//Epsilon_result/result[@err_code]/@err_code'
        ERROR_DETAIL     = '//Epsilon_result/result[@err_detail]/@err_detail'
      end

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

      def billing_params_base(amount, payment_method, detail)
        {
          contract_code: self.contract_code,
          user_id:       detail[:user_id],
          user_name:     detail[:user_name] || payment_method.name, # 後方互換性のために payment_method.name を残した
          user_mail_add: detail[:user_email],
          item_code:     detail[:item_code],
          item_name:     detail[:item_name],
          order_number:  detail[:order_number],
          mission_code:  detail[:mission_code],
          item_price:    amount,
          process_code:  detail[:process_code],
          user_agent:    "#{ActiveMerchant::Epsilon}-#{ActiveMerchant::Epsilon::VERSION}",
        }
      end

      def commit(action, params)
        url = (test? ? test_url : live_url)

        doc = doc(ssl_post(url + path(action), post_data(params)))

        response = parse_base(doc)
        response.merge!(parse(doc))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          test: test?
        )
      end

      def doc(body)
        # because of following error
        #   Nokogiri::XML::SyntaxError: Unsupported encoding x-sjis-cp932
        Nokogiri::XML(body.sub('x-sjis-cp932', 'UTF-8'))
      end

      def message_from(response)
        response[:message]
      end

      def parse_base(doc)
        transaction_code = doc.xpath(ResponseXpath::TRANSACTION_CODE).to_s
        error_code       = doc.xpath(ResponseXpath::ERROR_CODE).to_s
        error_detail     = uri_decode(doc.xpath(ResponseXpath::ERROR_DETAIL).to_s)

        {
          success:          [Epsilon::ResultCode::SUCCESS, Epsilon::ResultCode::THREE_D_SECURE].include?(result(doc)),
          message:          "#{error_code}: #{error_detail}",
          transaction_code: transaction_code,
          error_code:       error_code,
          error_detail:     error_detail,
        }
      end

      def post_data(parameters = {})
        parameters.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
      end

      def result(doc)
        doc.xpath(ResponseXpath::RESULT).to_s
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
