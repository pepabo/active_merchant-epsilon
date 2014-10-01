require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonGateway < Gateway
      self.test_url = 'https://beta.epsilon.jp/cgi-bin/order/direct_card_payment.cgi'
      self.live_url = 'https://example.com/live'

      self.supported_countries = ['JP']
      self.default_currency = 'JPY'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'http://www.example.net/'
      self.display_name = 'New Gateway'

      module ResponseXpath
        RESULT = '//Epsilon_result/result[@result]/@result'
        TRANSACTION_CODE = '//Epsilon_result/result[@trans_code]/@trans_code'
        ERROR_CODE = '//Epsilon_result/result[@err_code]/@err_code'
        ERROR_DETAIL = '//Epsilon_result/result[@err_detail]/@err_detail'
      end

      module MissionCode
        # クレジット1回、またはクレジット決済以外の場合
        PURCHASE = 1

        # | CODE | 登録月 | 解除月 | 同月内での登録解除 |
        # | 2    | 全額   | 無料   | 1ヶ月分            |
        # | 3    | 全額   | 全額   | 1ヶ月分            |
        # | 4    | 全額   | 日割   | 1ヶ月分            |
        # | 5    | 無料   | 無料   | 無料               |
        # | 6    | 無料   | 全角   | 1ヶ月分            |
        # | 7    | 無料   | 日割   | 日割               |
        # | 8    | 日割   | 無料   | 日割               |
        # | 9    | 日割   | 全額   | 1ヶ月分            |
        # | 10   | 日割   | 日割   | 日割               |
        RECURRING_2 = 2
        RECURRING_3 = 3
        RECURRING_4 = 4
        RECURRING_5 = 5
        RECURRING_6 = 6
        RECURRING_7 = 7
        RECURRING_8 = 8
        RECURRING_9 = 9
        RECURRING_10 = 10
      end

      def initialize(options={})
        super
      end

      def purchase(amount, credit_card, detail = {})
        params = billing_params(amount, credit_card, detail)

        commit('purchase', params)
      end

      def recurring(amount, credit_card, detail = {})
        detail[:mission_code] ||= MissionCode::RECURRING_2

        params = billing_params(amount, credit_card, detail)

        commit('purchase', params)
      end

      def authorize(money, payment, options={})
        raise
      end

      def capture(money, authorization, options={})
        raise
      end

      def refund(money, authorization, options={})
        raise
      end

      def void(authorization, options={})
        raise
      end

      def verify(credit_card, options={})
        raise
      end

      private

      def parse(body)
        xml = Nokogiri::XML(body.sub('x-sjis-cp932', 'CP932'))

        success = xml.xpath(ResponseXpath::RESULT).to_s == '1'
        transaction_code = xml.xpath(ResponseXpath::TRANSACTION_CODE).to_s
        error_code = xml.xpath(ResponseXpath::ERROR_CODE).to_s
        error_detail = URI.decode(
          xml.xpath(ResponseXpath::ERROR_DETAIL).to_s
        ).encode(Encoding::UTF_8, Encoding::CP932)

        {
          success: success,
          message: "#{error_code}: #{error_detail}",
          transaction_code: transaction_code,
          error_code: error_code,
          error_detail: error_detail
        }
      end

      def commit(_action, parameters)
        url = (test? ? test_url : live_url)
        response = parse(ssl_post(url, post_data(parameters)))

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

      def billing_params(amount, credit_card, detail)
        {
          contract_code: detail[:contract_code],
          user_id: detail[:user_id],
          user_name: credit_card.name,
          user_mail_add: detail[:user_email],
          item_code: detail[:item_code],
          item_name: detail[:item_name],
          order_number: detail[:order_number],
          st_code: '10000-0000-0000',
          mission_code: detail[:mission_code] || MissionCode::PURCHASE,
          item_price: amount,
          process_code: detail[:process_code] || 1,
          card_number: credit_card.number,
          expire_y: credit_card.year,
          expire_m: credit_card.month,
          user_agent: "#{ActiveMerchant::Epsilon}-#{ActiveMerchant::Epsilon::VERSION}",
        }
      end

      def authorization_from(response)
        {}
      end

      def post_data(parameters = {})
        parameters.map {|k, v| "#{k}=#{CGI.escape(v.to_s)}"}.join('&')
      end
    end
  end
end
