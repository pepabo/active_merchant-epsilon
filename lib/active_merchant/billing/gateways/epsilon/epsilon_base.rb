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

      cattr_accessor :contract_code, :proxy_address, :proxy_port, :encoding

      self.test_url            = 'https://beta.epsilon.jp/cgi-bin/order/'
      self.live_url            = 'https://secure.epsilon.jp/cgi-bin/order/'
      self.supported_countries = ['JP']
      self.default_currency    = 'JPY'
      self.homepage_url        = 'http://www.example.net/'
      self.display_name        = 'New Gateway'

      DEFAULT_RESPONSE_KEYS = [
        :transaction_code,
        :error_code,
        :error_detail,
        :card_number_mask,
        :card_brand,
        :card_expire,
        :three_d_secure,
        :acs_url,
        :pa_req,
        :tds2_url,
        :receipt_number,
        :receipt_date,
        :captured,
      ].freeze

      private

      def commit(path, request_params, response_keys = DEFAULT_RESPONSE_KEYS)
        parser = ResponseParser.new

        url = (test? ? test_url : live_url)
        response = parser.parse(ssl_post(File.join(url, path), post_data(request_params)), response_keys)

        options = {
          authorization: authorization_from(response),
          test:          test?
        }

        Response.new(success_from(response), message_from(response), response, options)
      end

      def post_data(parameters = {})
        parameters.map { |k, v| "#{k}=#{CGI.escape(encode_value(v.to_s))}" }.join('&')
      end

      def encode_value(value)
        return value unless encoding
        value.encode(encoding, invalid: :replace, undef: :replace)
      end

      def message_from(response)
        response[:message]
      end

      def success_from(response)
        response[:success]
      end

      def authorization_from(response)
        {}
      end
    end
  end
end
