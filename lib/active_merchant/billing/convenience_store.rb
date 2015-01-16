module ActiveMerchant
  module Billing
    class ConvenienceStore < Model
      SEVEN_ELEVEN = 11
      FAMILY_MART  = 21
      LAWSON       = 31
      SEICO_MART   = 32

      def initialize(code:, fullname_kana:, phone_number:)
        @code          = code
        @fullname_kana = fullname_kana
        @phone_number  = phone_number
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

      def validate
        errors_hash(validate_essential_attributes)
      end

      private

      def validate_essential_attributes
        errors = []

        if code.blank?
          errors << [:code, "cannot be empty"]
        elsif !valid_code?(code)
          errors << [:code, "is invalid"]
        end

        errors
      end

      def valid_code?(code)
        [SEVEN_ELEVEN, FAMILY_MART, LAWSON, SEICO_MART].include?(code.to_i)
      end
    end
  end
end
