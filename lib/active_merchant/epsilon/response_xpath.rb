module ActiveMerchant #:nodoc:
  module Epsilon
    module ResponseXpath
      RESULT                       = '//Epsilon_result/result[@result]/@result'
      TRANSACTION_CODE             = '//Epsilon_result/result[@trans_code]/@trans_code'
      ERROR_CODE                   = '//Epsilon_result/result[@err_code]/@err_code'
      ERROR_DETAIL                 = '//Epsilon_result/result[@err_detail]/@err_detail'
      RECEIPT_NUMBER               = '//Epsilon_result/result[@receipt_no][1]/@receipt_no'
      RECEIPT_DATE                 = '//Epsilon_result/result[@receipt_date][1]/@receipt_date'
      CONVENIENCE_STORE_LIMIT_DATE = '//Epsilon_result/result[@conveni_limit][1]/@conveni_limit'
      CARD_NUMBER_MASK             = '//Epsilon_result/result[@card_number_mask]/@card_number_mask'
      CARD_BRAND                   = '//Epsilon_result/result[@card_brand]/@card_brand'
      ACS_URL                      = '//Epsilon_result/result[@acsurl]/@acsurl' # ACS (Access Control Server)
      PA_REQ                       = '//Epsilon_result/result[@pareq]/@pareq' # PAReq (payment authentication request)
    end
  end
end
