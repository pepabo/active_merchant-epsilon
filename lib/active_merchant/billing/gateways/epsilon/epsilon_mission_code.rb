module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module EpsilonMissionCode
      # クレジット1回、またはクレジット決済以外の場合
      PURCHASE = 1

      # | CODE | 登録月 | 解除月 | 同月内での登録解除 |
      # | 2    | 全額   | 無料   | 1ヶ月分            |
      # | 3    | 全額   | 全額   | 1ヶ月分            |
      # | 4    | 全額   | 日割   | 1ヶ月分            |
      # | 5    | 無料   | 無料   | 無料               |
      # | 6    | 無料   | 全角   | 1ヶ月分            |
      # | 7    | 無料   | 日割   | 日割               |
      # | 8    | 日割   | 無料   | 日割               |
      # | 9    | 日割   | 全額   | 1ヶ月分            |
      # | 10   | 日割   | 日割   | 日割               |
      RECURRING_2  = 2
      RECURRING_3  = 3
      RECURRING_4  = 4
      RECURRING_5  = 5
      RECURRING_6  = 6
      RECURRING_7  = 7
      RECURRING_8  = 8
      RECURRING_9  = 9
      RECURRING_10 = 10

      RECURRINGS = (2..10).to_a.freeze
    end
  end
end
