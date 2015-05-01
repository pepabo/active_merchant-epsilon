require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EpsilonCommon
      module ResponseXpath
        RESULT                       = '//Epsilon_result/result[@result]/@result'
        TRANSACTION_CODE             = '//Epsilon_result/result[@trans_code]/@trans_code'
        ERROR_CODE                   = '//Epsilon_result/result[@err_code]/@err_code'
        ERROR_DETAIL                 = '//Epsilon_result/result[@err_detail]/@err_detail'
        CARD_NUMBER_MASK             = '//Epsilon_result/result[@card_number_mask]/@card_number_mask'
        CARD_BRAND                   = '//Epsilon_result/result[@card_brand]/@card_brand'
        ACS_URL                      = '//Epsilon_result/result[@acsurl]/@acsurl' # ACS (Access Control Server)
        PA_REQ                       = '//Epsilon_result/result[@pareq]/@pareq' # PAReq (payer authentication request)
        RECEIPT_NUMBER               = '//Epsilon_result/result[@receipt_no][1]/@receipt_no'
        RECEIPT_DATE                 = '//Epsilon_result/result[@receipt_date][1]/@receipt_date'
        CONVENIENCE_STORE_LIMIT_DATE = '//Epsilon_result/result[@conveni_limit][1]/@conveni_limit'
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

      private

      def authorization_from(response)
        {}
      end

      def commit(path, params)
        url          = (test? ? test_url : live_url)
        raw_response = ssl_post(File.join(url, path), post_data(params))
        response     = parse(raw_response)

        options = {
          authorization: authorization_from(response),
          test:          test?
        }

        Response.new(success_from(response), message_from(response), response, options)
      end

      def message_from(response)
        response[:message]
      end

      def parse(body)
        # because of following error
        #   Nokogiri::XML::SyntaxError: Unsupported encoding x-sjis-cp932
        xml = Nokogiri::XML(body.sub('x-sjis-cp932', 'UTF-8'))

        result                       = xml.xpath(ResponseXpath::RESULT).to_s
        transaction_code             = xml.xpath(ResponseXpath::TRANSACTION_CODE).to_s
        error_code                   = xml.xpath(ResponseXpath::ERROR_CODE).to_s
        error_detail                 = uri_decode(xml.xpath(ResponseXpath::ERROR_DETAIL).to_s)
        card_number_mask             = uri_decode(xml.xpath(ResponseXpath::CARD_NUMBER_MASK).to_s)
        card_brand                   = uri_decode(xml.xpath(ResponseXpath::CARD_BRAND).to_s)
        acs_url                      = uri_decode(xml.xpath(ResponseXpath::ACS_URL).to_s)
        pa_req                       = uri_decode(xml.xpath(ResponseXpath::PA_REQ).to_s)
        receipt_number               = xml.xpath(ResponseXpath::RECEIPT_NUMBER).to_s
        receipt_date                 = uri_decode(xml.xpath(ResponseXpath::RECEIPT_DATE).to_s)
        convenience_store_limit_date = uri_decode(xml.xpath(ResponseXpath::CONVENIENCE_STORE_LIMIT_DATE).to_s)

        {
          success:                      [Epsilon::ResultCode::SUCCESS, Epsilon::ResultCode::THREE_D_SECURE].include?(result),
          message:                      "#{error_code}: #{error_detail}",
          transaction_code:             transaction_code,
          error_code:                   error_code,
          error_detail:                 error_detail,
          card_number_mask:             card_number_mask,
          card_brand:                   card_brand,
          three_d_secure:               result == Epsilon::ResultCode::THREE_D_SECURE,
          acs_url:                      acs_url,
          pa_req:                       pa_req,
          receipt_number:               receipt_number,
          receipt_date:                 receipt_date,
          convenience_store_limit_date: convenience_store_limit_date,
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
