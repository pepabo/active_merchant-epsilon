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
        result                       = doc.xpath(Epsilon::ResponseXpath::RESULT).to_s
        transaction_code             = doc.xpath(Epsilon::ResponseXpath::TRANSACTION_CODE).to_s
        error_code                   = doc.xpath(Epsilon::ResponseXpath::ERROR_CODE).to_s
        error_detail                 = uri_decode(doc.xpath(Epsilon::ResponseXpath::ERROR_DETAIL).to_s)
        receipt_number               = doc.xpath(Epsilon::ResponseXpath::RECEIPT_NUMBER).to_s
        receipt_date                 = uri_decode(doc.xpath(Epsilon::ResponseXpath::RECEIPT_DATE).to_s)
        convenience_store_limit_date = uri_decode(doc.xpath(Epsilon::ResponseXpath::CONVENIENCE_STORE_LIMIT_DATE).to_s)
        card_number_mask             = uri_decode(doc.xpath(Epsilon::ResponseXpath::CARD_NUMBER_MASK).to_s)
        card_brand                   = uri_decode(doc.xpath(Epsilon::ResponseXpath::CARD_BRAND).to_s)
        acs_url                      = uri_decode(doc.xpath(Epsilon::ResponseXpath::ACS_URL).to_s)
        pa_req                       = uri_decode(doc.xpath(Epsilon::ResponseXpath::PA_REQ).to_s)

        {
          success:                      result == Epsilon::ResultCode::SUCCESS || result == Epsilon::ResultCode::THREE_D_SECURE,
          message:                      "#{error_code}: #{error_detail}",
          transaction_code:             transaction_code,
          error_code:                   error_code,
          error_detail:                 error_detail,
          receipt_number:               receipt_number,
          receipt_date:                 receipt_date,
          convenience_store_limit_date: convenience_store_limit_date,
          card_number_mask:             card_number_mask,
          card_brand:                   card_brand,
          three_d_secure:               result == Epsilon::ResultCode::THREE_D_SECURE,
          acs_url:                      acs_url,
          pa_req:                       pa_req,
        }
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
