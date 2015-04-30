require 'nokogiri'
require 'active_support/core_ext/string'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonConvenienceStoreGateway < Gateway
      include EpsilonCommon

      PATHS = {
        purchase: 'receive_order3.cgi',
      }.freeze

      private

      # TODO: クレジットカードと共通部分を基底モジュールに切り出す

      def parse(body)
        # because of following error
        #   Nokogiri::XML::SyntaxError: Unsupported encoding x-sjis-cp932
        xml = Nokogiri::XML(body.sub('x-sjis-cp932', 'UTF-8'))

        result                       = xml.xpath(Epsilon::ResponseXpath::RESULT).to_s
        transaction_code             = xml.xpath(Epsilon::ResponseXpath::TRANSACTION_CODE).to_s
        error_code                   = xml.xpath(Epsilon::ResponseXpath::ERROR_CODE).to_s
        error_detail                 = uri_decode(xml.xpath(Epsilon::ResponseXpath::ERROR_DETAIL).to_s)
        receipt_number               = xml.xpath(Epsilon::ResponseXpath::RECEIPT_NUMBER).to_s
        receipt_date                 = uri_decode(xml.xpath(Epsilon::ResponseXpath::RECEIPT_DATE).to_s)
        convenience_store_limit_date = uri_decode(xml.xpath(Epsilon::ResponseXpath::CONVENIENCE_STORE_LIMIT_DATE).to_s)
        card_number_mask             = uri_decode(xml.xpath(Epsilon::ResponseXpath::CARD_NUMBER_MASK).to_s)
        card_brand                   = uri_decode(xml.xpath(Epsilon::ResponseXpath::CARD_BRAND).to_s)
        acs_url                      = uri_decode(xml.xpath(Epsilon::ResponseXpath::ACS_URL).to_s)
        pa_req                       = uri_decode(xml.xpath(Epsilon::ResponseXpath::PA_REQ).to_s)

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

      def uri_decode(string)
        URI.decode(string).encode(Encoding::UTF_8, Encoding::CP932)
      end

      def commit(action, parameters)
        url = (test? ? test_url : live_url)

        path = PATHS[action.to_sym]

        response = parse(ssl_post(url + path, post_data(parameters)))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          test: test?
        )
      end

      def success_from(response)
        response[:success]
      end

      def message_from(response)
        response[:message]
      end

      def billing_params(amount, payment_method, detail)
        params = billing_params_base(amount, payment_method, detail)

        params.merge(
          user_tel:     payment_method.phone_number,
          st_code:      '00100-0000-0000',
          xml:          1,
          conveni_code: payment_method.code,
        )
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

      def authorization_from(response)
        {}
      end

      def post_data(parameters = {})
        parameters.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
      end
    end
  end
end
