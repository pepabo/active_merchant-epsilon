module ActiveMerchant
  module Billing
    class ConvenienceStore
      SevenEleven = 11
      FamilyMart = 21
      Lawson = 31
      Seicomart = 32

      def initialize(code:, fullname_kana:, phone_number:)
        @code = code
        @fullname_kana = fullname_kana
        @phone_number = phone_number
      end

      def code
        @code
      end

      def name
        @fullname_kana
      end

      def phone_number
        @phone_number
      end
    end
  end
end
