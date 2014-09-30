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

      def initialize(options={})
        super
      end

      def purchase(money, credit_card, detail = {})
        params = {
          contract_code: detail[:contract_code],
          user_id: detail[:user_id],
          user_name: credit_card.name,
          user_mail_add: detail[:user_email],
          item_code: detail[:item_code],
          item_name: detail[:item_name],
          order_number: detail[:order_number],
          st_code: '10000-0000-0000',
          mission_code: 1,
          item_price: money,
          process_code: 1,
          card_number: credit_card.number,
          expire_y: credit_card.year,
          expire_m: credit_card.month,
          user_agent: 'test'
        }

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

        success = xml.xpath('//Epsilon_result/result[@result]/@result').to_s == '1'
        error_code = xml.xpath('//Epsilon_result/result[@err_code]/@err_code').to_s
        error_detail = URI.decode(xml.xpath('//Epsilon_result/result[@err_detail]/@err_detail').to_s).encode(Encoding::UTF_8, Encoding::CP932)
        trans_code = xml.xpath('//Epsilon_result/result[@trans_code]/@trans_code').to_s

        {
          success: success,
          message: "#{error_code}: #{error_detail}",
          trans_code: trans_code,
          err_code: error_code,
          err_detail: error_detail
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

      def authorization_from(response)
        {}
      end

      def post_data(parameters = {})
        parameters.map {|k, v| "#{k}=#{CGI.escape(v.to_s)}"}.join('&')
      end
    end
  end
end
