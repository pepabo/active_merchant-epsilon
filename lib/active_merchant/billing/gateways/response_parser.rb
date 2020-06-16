require 'cgi'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ResponseParser
      def parse(body, required_items)
        # because of following error
        #   Nokogiri::XML::SyntaxError: Unsupported encoding x-sjis-cp932
        @xml = Nokogiri::XML(body.sub('x-sjis-cp932', 'UTF-8'))
        @result = @xml.xpath(ResponseXpath::RESULT).to_s

        response = {
          success: [ResultCode::SUCCESS, ResultCode::THREE_D_SECURE].include?(@result) || !state.empty?,
          message: "#{error_code}: #{error_detail}"
        }

        required_items.each do |item_name|
          response[item_name] = self.send(item_name)
        end

        response
      end

      private

      def transaction_code
        @xml.xpath(ResponseXpath::TRANSACTION_CODE).to_s
      end

      def error_code
        @xml.xpath(ResponseXpath::ERROR_CODE).to_s
      end

      def error_detail
        uri_decode(@xml.xpath(ResponseXpath::ERROR_DETAIL).to_s)
      end

      def card_number_mask
        uri_decode(@xml.xpath(ResponseXpath::CARD_NUMBER_MASK).to_s)
      end

      def card_brand
        uri_decode(@xml.xpath(ResponseXpath::CARD_BRAND).to_s)
      end

      def card_expire
        uri_decode(@xml.xpath(ResponseXpath::CARD_EXPIRE).to_s)
      end

      def three_d_secure
        @result == ResultCode::THREE_D_SECURE
      end

      def acs_url
        uri_decode(@xml.xpath(ResponseXpath::ACS_URL).to_s)
      end

      def pa_req
        uri_decode(@xml.xpath(ResponseXpath::PA_REQ).to_s)
      end

      def receipt_number
        @xml.xpath(ResponseXpath::RECEIPT_NUMBER).to_s
      end

      def receipt_date
        uri_decode(@xml.xpath(ResponseXpath::RECEIPT_DATE).to_s)
      end

      def convenience_store_limit_date
        uri_decode(@xml.xpath(ResponseXpath::CONVENIENCE_STORE_LIMIT_DATE).to_s)
      end

      def convenience_store_payment_slip_url
        uri_decode(@xml.xpath(ResponseXpath::CONVENIENCE_STORE_PAYMENT_SLIP_URL).to_s)
      end

      def company_code
        @xml.xpath(ResponseXpath::COMPANY_CODE).to_s
      end

      def account_number
        @xml.xpath(ResponseXpath::ACCOUNT_NUMBER).to_s
      end

      def account_name
        uri_decode(@xml.xpath(ResponseXpath::ACCOUNT_NAME).to_s)
      end

      def bank_code
        @xml.xpath(ResponseXpath::BANK_CODE).to_s
      end

      def bank_name
        uri_decode(@xml.xpath(ResponseXpath::BANK_NAME).to_s)
      end

      def branch_code
        @xml.xpath(ResponseXpath::BRANCH_CODE).to_s
      end

      def branch_name
        uri_decode(@xml.xpath(ResponseXpath::BRANCH_NAME).to_s)
      end

      def state
        @xml.xpath(ResponseXpath::STATE).to_s
      end

      def payment_code
        @xml.xpath(ResponseXpath::PAYMENT_CODE).to_s
      end

      def item_price
        @xml.xpath(ResponseXpath::ITEM_PRICE).to_s
      end

      def amount
        @xml.xpath(ResponseXpath::AMOUNT).to_s
      end

      def redirect
        uri_decode(@xml.xpath(ResponseXpath::REDIRECT).to_s)
      end

      def captured
        @xml.xpath(ResponseXpath::CAPTURED).to_s != '1'
      end

      def uri_decode(string)
        CGI.unescape(string).encode(Encoding::UTF_8, Encoding::CP932)
      end

      module ResponseXpath
        RESULT                             = '//Epsilon_result/result[@result]/@result'
        TRANSACTION_CODE                   = '//Epsilon_result/result[@trans_code]/@trans_code'
        ERROR_CODE                         = '//Epsilon_result/result[@err_code]/@err_code'
        ERROR_DETAIL                       = '//Epsilon_result/result[@err_detail]/@err_detail'
        CARD_NUMBER_MASK                   = '//Epsilon_result/result[@card_number_mask]/@card_number_mask'
        CARD_BRAND                         = '//Epsilon_result/result[@card_brand]/@card_brand'
        CARD_EXPIRE                        = '//Epsilon_result/result[@card_expire]/@card_expire'
        ACS_URL                            = '//Epsilon_result/result[@acsurl]/@acsurl' # ACS (Access Control Server)
        PA_REQ                             = '//Epsilon_result/result[@pareq]/@pareq' # PAReq (payer authentication request)
        RECEIPT_NUMBER                     = '//Epsilon_result/result[@receipt_no][1]/@receipt_no'
        RECEIPT_DATE                       = '//Epsilon_result/result[@receipt_date][1]/@receipt_date'
        CONVENIENCE_STORE_LIMIT_DATE       = '//Epsilon_result/result[@conveni_limit][1]/@conveni_limit'
        CONVENIENCE_STORE_PAYMENT_SLIP_URL = '//Epsilon_result/result[@haraikomi_url][1]/@haraikomi_url'
        COMPANY_CODE                       = '//Epsilon_result/result[@kigyou_code][1]/@kigyou_code'
        ACCOUNT_NUMBER                     = '//Epsilon_result/result[@account_no][1]/@account_no'
        ACCOUNT_NAME                       = '//Epsilon_result/result[@account_name][1]/@account_name'
        BANK_CODE                          = '//Epsilon_result/result[@bank_code][1]/@bank_code'
        BANK_NAME                          = '//Epsilon_result/result[@bank_name][1]/@bank_name'
        BRANCH_CODE                        = '//Epsilon_result/result[@branch_code][1]/@branch_code'
        BRANCH_NAME                        = '//Epsilon_result/result[@branch_name][1]/@branch_name'
        STATE                              = '//Epsilon_result/result[@state]/@state'
        ITEM_PRICE                         = '//Epsilon_result/result[@item_price]/@item_price'
        PAYMENT_CODE                       = '//Epsilon_result/result[@payment_code]/@payment_code'
        AMOUNT                             = '//Epsilon_result/result[@amount]/@amount'
        REDIRECT                           = '//Epsilon_result/result[@redirect]/@redirect'
        CAPTURED                           = '//Epsilon_result/result[@kari_flag]/@kari_flag'
      end

      module ResultCode
        FAILURE        = '0'
        SUCCESS        = '1'
        THREE_D_SECURE = '5'
        SYSTEM_ERROR   = '9'
      end
    end
  end
end
