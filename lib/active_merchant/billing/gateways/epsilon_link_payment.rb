module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonLinkPaymentGateway < EpsilonBaseGateway

      RESPONSE_KEYS = DEFAULT_RESPONSE_KEYS + [
        :redirect,
      ]

      def purchase(amount, detail = {}, delivery_info_required = true)
        params = {
          contract_code: self.contract_code,
          user_id:       detail[:user_id],
          user_name:     detail[:user_name],
          user_mail_add: detail[:user_email],
          item_code:     detail[:item_code],
          item_name:     detail[:item_name],
          order_number:  detail[:order_number],
          st_code:       detail[:st_code],
          mission_code:  EpsilonMissionCode::PURCHASE,
          item_price:    amount,
          process_code:  EpsilonProcessCode::FIRST,
          xml: 1, # 応答形式。1: xml形式を固定
        }

        # 注文情報の詳細が必要な場合のみ、セットする
        if delivery_info_required
          params[:delivery_code] = 99 # 配送区分。99で固定
          params[:consignee_postal] = detail[:consignee_postal]
          params[:consignee_name] = detail[:consignee_name]
          params[:consignee_address] = detail[:consignee_address]
          params[:consignee_tel] = detail[:consignee_tel]
          params[:orderer_postal] = detail[:orderer_postal]
          params[:orderer_name] = detail[:orderer_name]
          params[:orderer_address] = detail[:orderer_address]
          params[:orderer_tel] = detail[:orderer_tel]
        end

        params[:memo1] = detail[:memo1] if detail.has_key?(:memo1)
        params[:memo2] = detail[:memo2] if detail.has_key?(:memo2)
        params[:user_tel] = detail[:user_tel] if detail.has_key?(:user_tel)

        if three_d_secure_2?(detail)
          params.merge!(detail.slice(*EpsilonRiskBaseAuthParams::KEYS).compact)
        end

        commit('receive_order3.cgi', params, RESPONSE_KEYS)
      end

      def void(order_number)
        params = {
          contract_code: self.contract_code,
          order_number: order_number
        }

        commit('cancel_payment.cgi', params)
      end

      private

      def three_d_secure_2?(detail)
        EpsilonRiskBaseAuthParams.three_d_secure_2?(detail[:tds_flag])
      end
    end
  end
end
