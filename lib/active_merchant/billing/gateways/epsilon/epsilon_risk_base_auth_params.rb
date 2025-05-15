module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EpsilonRiskBaseAuthParams
      KEYS = %i[
        tds_flag billAddrCity billAddrCountry billAddrLine1 billAddrLine2 billAddrLine3
        billAddrPostCode billAddrState shipAddrCity shipAddrCountry shipAddrLine1 shipAddrLine2
        shipAddrLine3 shipAddrPostCode shipAddrState chAccAgeInd chAccChange
        chAccChangeIndchAccDate chAccPwdChange chAccPwChangeInd nbPurchaseAccount paymentAccAge
        paymentAccInd provisionAttemptsDay shipAddressUsage shipAddressUsageInd shipNameIndicator
        suspiciousAccActivity txnActivityDay txnActivityYear threeDSReqAuthData threeDSReqAuthMethod
        threeDSReqAuthTimestamp addrMatch cardholderName homePhone mobilePhone
        workPhone challengeInd deliveryEmailAddress deliveryTimeframe giftCardAmount
        giftCardCount preOrderDate preOrderPurchaseInd reorderItemsInd shipIndicator
      ].freeze

      THREE_D_SECURE_2_INDICATORS = [21, 22].freeze

      def three_d_secure_2?(tds_flag)
        THREE_D_SECURE_2_INDICATORS.include?(tds_flag)
      end

      module_function :three_d_secure_2?
    end
  end
end
