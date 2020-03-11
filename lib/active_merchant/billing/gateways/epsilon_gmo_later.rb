module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonGmoLaterGateway < EpsilonBaseGateway
      def purchase(amount, detail = {})
        params = {
          contract_code: self.contract_code,
          user_id:       detail[:user_id],
          user_name:     detail[:user_name],
          user_mail_add: detail[:user_email],
          item_code:     detail[:item_code],
          item_name:     detail[:item_name],
          order_number:  detail[:order_number],
          st_code:       '00000-0000-00000-00000-00100-00000-00000',
          mission_code:  EpsilonMissionCode::PURCHASE,
          item_price:    amount,
          process_code:  EpsilonProcessCode::FIRST,
          xml: 1, # 応答形式。1: xml形式を固定
          delivery_code: 99, # 配送区分。99で固定
          consignee_postal: detail[:consignee_postal],
          consignee_name: detail[:consignee_name],
          consignee_address: detail[:consignee_address],
          consignee_tel: detail[:consignee_tel],
          orderer_postal: detail[:orderer_postal],
          orderer_name: detail[:orderer_name],
          orderer_address: detail[:orderer_address],
          orderer_tel: detail[:orderer_tel],
          version: 2, # 推奨文字コードがUTF8の方を指定
        }

        params[:memo1] = detail[:memo1] if detail.has_key?(:memo1)
        params[:memo2] = detail[:memo2] if detail.has_key?(:memo2)
        params[:user_tel] = detail[:user_tel] if detail.has_key?(:user_tel)

        commit('receive_order3.cgi', params)
      end
    end
  end
end
