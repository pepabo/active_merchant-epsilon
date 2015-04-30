require 'nokogiri'
require 'active_support/core_ext/string'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonConvenienceStoreGateway < Gateway
      include EpsilonCommon

      module ResponseXpath
        RECEIPT_NUMBER               = '//Epsilon_result/result[@receipt_no][1]/@receipt_no'
        RECEIPT_DATE                 = '//Epsilon_result/result[@receipt_date][1]/@receipt_date'
        CONVENIENCE_STORE_LIMIT_DATE = '//Epsilon_result/result[@conveni_limit][1]/@conveni_limit'
      end

      private

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

      def parse(doc)
        receipt_number               = doc.xpath(ResponseXpath::RECEIPT_NUMBER).to_s
        receipt_date                 = uri_decode(doc.xpath(ResponseXpath::RECEIPT_DATE).to_s)
        convenience_store_limit_date = uri_decode(doc.xpath(ResponseXpath::CONVENIENCE_STORE_LIMIT_DATE).to_s)

        {
          receipt_number:               receipt_number,
          receipt_date:                 receipt_date,
          convenience_store_limit_date: convenience_store_limit_date,
        }
      end

      def path(action)
        case action.to_sym
        when :purchase then 'receive_order3.cgi'
        end
      end
    end
  end
end
