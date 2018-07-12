module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonVirtualAccountGateway < EpsilonBaseGateway
      RESPONSE_KEYS = [
        :transaction_code,
        :error_code,
        :error_detail,
        :account_number,
        :account_name,
        :bank_code,
        :bank_name,
        :branch_code,
        :branch_name
      ]

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
          user_agent:     "#{ActiveMerchant::Epsilon}-#{ActiveMerchant::Epsilon::VERSION}",
        }

        params[:memo1] = detail[:memo1] if detail.has_key?(:memo1)
        params[:memo2] = detail[:memo2] if detail.has_key?(:memo2)
        params[:user_name_kana] = detail[:user_name_kana] if detail.has_key?(:user_name_kana)

        commit('direct_virtual_account.cgi', params, RESPONSE_KEYS)
      end
    end
  end
end