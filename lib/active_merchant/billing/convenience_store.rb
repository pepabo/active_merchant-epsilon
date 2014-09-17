module ActiveMerchant
  module Billing
    class ConvenienceStore
      SevenEleven = 11

      def initialize(code:, fullname_kana:, phone_nubmer:)
        @code = code
        @fullname_kana = fullname_kana
        @phone_nubmer = phone_nubmer
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
