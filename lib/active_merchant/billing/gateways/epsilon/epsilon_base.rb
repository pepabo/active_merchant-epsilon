require 'nokogiri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc

    #
    # This is the base gateway for concrete payment gateway for Epsilon
    #
    # === Create a new EpsilonGatway
    #
    # class EpsilonSampleGateway < EpsilonBaseGateway
    #   def purchase(amount, payment_method, detail = {})
    #     request_params = {
    #       contract_code: self.contract_code,
    #       user_id:       detail[:user_id],
    #       item_code:     detail[:item_code],
    #       order_number:  detail[:order_number],
    #       item_price:    amount,
    #     }
    #
    #     request_path = 'purchase'
    #
    #     commit(request_path, request_paramsparams)
    #   end
    # end
    #

    class EpsilonBaseGateway < Gateway

      self.abstract_class = true

      module ResponseXpath
        RESULT                             = '//Epsilon_result/result[@result]/@result'
        TRANSACTION_CODE                   = '//Epsilon_result/result[@trans_code]/@trans_code'
        ERROR_CODE                         = '//Epsilon_result/result[@err_code]/@err_code'
        ERROR_DETAIL                       = '//Epsilon_result/result[@err_detail]/@err_detail'
        CARD_NUMBER_MASK                   = '//Epsilon_result/result[@card_number_mask]/@card_number_mask'
        CARD_BRAND                         = '//Epsilon_result/result[@card_brand]/@card_brand'
        ACS_URL                            = '//Epsilon_result/result[@acsurl]/@acsurl' # ACS (Access Control Server)
        PA_REQ                             = '//Epsilon_result/result[@pareq]/@pareq' # PAReq (payer authentication request)
        RECEIPT_NUMBER                     = '//Epsilon_result/result[@receipt_no][1]/@receipt_no'
        RECEIPT_DATE                       = '//Epsilon_result/result[@receipt_date][1]/@receipt_date'
        CONVENIENCE_STORE_LIMIT_DATE       = '//Epsilon_result/result[@conveni_limit][1]/@conveni_limit'
        CONVENIENCE_STORE_PAYMENT_SLIP_URL = '//Epsilon_result/result[@haraikomi_url][1]/@haraikomi_url'
      end

      module ResultCode
        FAILURE        = '0'
        SUCCESS        = '1'
        THREE_D_SECURE = '5'
        SYSTEM_ERROR   = '9'
      end

      cattr_accessor :contract_code, :proxy_address, :proxy_port

      self.test_url            = 'https://beta.epsilon.jp/cgi-bin/order/'
      self.live_url            = 'https://secure.epsilon.jp/cgi-bin/order/'
      self.supported_countries = ['JP']
      self.default_currency    = 'JPY'
      self.homepage_url        = 'http://www.example.net/'
      self.display_name        = 'New Gateway'

      private

      def authorization_from(response)
        {}
      end

      def commit(path, request_params)
        parser = ResponseParser.new

        url = (test? ? test_url : live_url)
        response = parser.parse(ssl_post(File.join(url, path), post_data(request_params)))

        options = {
          authorization: authorization_from(response),
          test:          test?
        }

        Response.new(success_from(response), message_from(response), response, options)
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
    end
  end
end
