require 'nokogiri'
require 'active_support/core_ext/string'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonGateway < Gateway
      include EpsilonCommon

      module ResponseXpath
        CARD_NUMBER_MASK = '//Epsilon_result/result[@card_number_mask]/@card_number_mask'
        CARD_BRAND       = '//Epsilon_result/result[@card_brand]/@card_brand'
        ACS_URL          = '//Epsilon_result/result[@acsurl]/@acsurl' # ACS (Access Control Server)
        PA_REQ           = '//Epsilon_result/result[@pareq]/@pareq' # PAReq (payment authentication request)
      end

      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      def registered_purchase(amount, detail = {})
        commit(
          'registered_purchase',
          contract_code: self.contract_code,
          user_id:       detail[:user_id],
          user_name:     detail[:user_name],
          user_mail_add: detail[:user_email],
          item_code:     detail[:item_code],
          item_name:     detail[:item_name],
          order_number:  detail[:order_number],
          st_code:       '10000-0000-0000',
          mission_code:  Epsilon::MissionCode::PURCHASE,
          item_price:    amount,
          process_code:  2,
          xml:           1
        )
      end

      def recurring(amount, credit_card, detail = {})
        detail[:process_code] = 1
        detail[:mission_code] ||= Epsilon::MissionCode::RECURRING_2

        requires!(detail, [:mission_code, *Epsilon::MissionCode::RECURRINGS])

        params = billing_params(amount, credit_card, detail)

        commit('purchase', params)
      end

      def registered_recurring(amount, detail = {})
        commit(
          'registered_recurring',
          contract_code: self.contract_code,
          user_id:       detail[:user_id],
          user_name:     detail[:user_name],
          user_mail_add: detail[:user_email],
          item_code:     detail[:item_code],
          item_name:     detail[:item_name],
          order_number:  detail[:order_number],
          st_code:       '10000-0000-0000',
          mission_code:  detail[:mission_code],
          item_price:    amount,
          process_code:  2,
          xml:           1
        )
      end

      def cancel_recurring(user_id:, item_code:)
        commit(
          'cancel_recurring',
          contract_code: self.contract_code,
          user_id:       user_id,
          item_code:     item_code,
          xml:           1,
          process_code:  8
        )
      end

      def find_user(user_id:)
        commit(
          'find_user',
          contract_code: self.contract_code,
          user_id:       user_id
        )
      end

      #
      # Second request for 3D secure
      #
      def authenticate(order_number:, three_d_secure_pa_res:)
        params = {
          contract_code:  self.contract_code,
          order_number:   order_number,
          tds_check_code: 2,
          tds_pares:      three_d_secure_pa_res,
        }

        commit('purchase', params)
      end

      def void(order_number)
        commit(
          'void',
          contract_code: self.contract_code,
          order_number:  order_number
        )
      end

      def verify(credit_card, options={})
        o = options.dup
        o[:order_number] ||= "#{Time.now.to_i}#{options[:user_id]}".first(32)
        o[:item_code] = 'verifycreditcard'
        o[:item_name] = 'verify credit card'

        MultiResponse.run(:use_first_response) do |r|
          r.process { purchase(1, credit_card, o) }
          r.process(:ignore_result) { void(o[:order_number]) }
        end
      end

      private

      def billing_params(amount, payment_method, detail)
        params = billing_params_base(amount, payment_method, detail)

        params.merge!(
          st_code:        '10000-0000-0000',
          card_number:    payment_method.number,
          expire_y:       payment_method.year,
          expire_m:       payment_method.month,
          card_st_code:   detail[:credit_type],
          pay_time:       detail[:payment_time],
          tds_check_code: detail[:three_d_secure_check_code],
        )

        if payment_method.class.requires_verification_value?
          params.merge!(
            security_code:  payment_method.verification_value,
            security_check: 1, # use security code
          )
        end

        params
      end

      def parse(doc)
        card_number_mask = uri_decode(doc.xpath(ResponseXpath::CARD_NUMBER_MASK).to_s)
        card_brand       = uri_decode(doc.xpath(ResponseXpath::CARD_BRAND).to_s)
        acs_url          = uri_decode(doc.xpath(ResponseXpath::ACS_URL).to_s)
        pa_req           = uri_decode(doc.xpath(ResponseXpath::PA_REQ).to_s)

        {
          card_number_mask: card_number_mask,
          card_brand:       card_brand,
          three_d_secure:   result(doc) == Epsilon::ResultCode::THREE_D_SECURE,
          acs_url:          acs_url,
          pa_req:           pa_req,
        }
      end

      def path(action)
        case action.to_sym
        when :purchase             then 'direct_card_payment.cgi'
        when :registered_recurring then 'direct_card_payment.cgi'
        when :registered_purchase  then 'direct_card_payment.cgi'
        when :cancel_recurring     then 'receive_order3.cgi'
        when :void                 then 'cancel_payment.cgi'
        when :find_user            then 'get_user_info.cgi'
        end
      end
    end
  end
end
