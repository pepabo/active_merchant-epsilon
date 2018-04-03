module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EpsilonProcessCode
      FIRST              = 1  # 初回課金
      REGISTERED         = 2  # 登録済み課金
      ONLY_REGISTER      = 3  # 登録のみ
      CHANGE_INFORMATION = 4  # 登録内容変更
      CANCEL_WITHDRAWAL  = 7  # 退会取り消し
      CANCEL_MONTHLY     = 8  # 月次課金解除
      WITHDRAWAL         = 9  # 退会
    end
  end
end
