module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class EpsilonGmoIdGateway < EpsilonBaseGateway
      PATHS = {
        purchase:                'receive_order_gmo2.cgi',
        void:                    'cancel_payment.cgi',
      }.freeze

      def purchase(amount, detail = {})
        params = {
          contract_code: self.contract_code,
          user_id: detail[:user_id],
          user_name: detail[:user_name],
          user_mail_add: detail[:user_email],
          item_code: detail[:item_code],
          item_name: detail[:item_name],
          order_number: detail[:order_number],
          st_code: '10000-0000-00000-00000-00000-00000-00000',
          mission_code: EpsilonMissionCode::PURCHASE,
          item_price: amount,
          process_code: EpsilonProcessCode::REGISTERED,
          gmo_id: detail[:gmo_id],
          gmo_card_id: detail[:gmo_card_id],
        }

        commit(PATHS[:purchase], params)
      end

      def void(order_number)
        params = {
          contract_code: self.contract_code,
          order_number:  order_number,
        }

        commit(PATHS[:void], params)
      end
    end
  end
end
