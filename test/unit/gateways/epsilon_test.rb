require 'test_helper'

class EpsilonGatewayTest < MiniTest::Test
  include SampleCreditCardMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGateway.new
  end

  class NotFoundTest < self
    def setup
      stub_gateway(status: 404)
    end

    def test_raise_error
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class ForbiddenTest < self
    def setup
      stub_gateway(status: 403)
    end

    def test_raise_error
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class ServerErrorTest < self
    def setup
      stub_gateway(status: 500)
    end

    def test_raise_error
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class SuccessTest < self
    def setup
      @xml = fixture_xml('success.xml')
      stub_gateway(status: 200, body: @xml.to_s)

      @response = gateway.purchase(100, valid_credit_card, purchase_detail)
    end

    def test_success?
      assert @response.success?
    end

    def test_transaction_code
      assert_equal(
        @xml.css('result[trans_code]').first['trans_code'],
        @response.params['transaction_code']
      )
    end
  end

  class PurchaseFailTest < self
    def setup
      @xml = fixture_xml('invalid_card_number.xml')
      stub_gateway(status: 200, body: @xml.to_s)

      @response = gateway.purchase(100, invalid_credit_card, purchase_detail)
    end

    def test_success?
      assert_equal false, @response.success?
    end

    def test_transaction_code
      assert_equal(
        @xml.css('result[trans_code]').first['trans_code'],
        @response.params['transaction_code']
      )
    end

    def test_error_code
      assert_equal(
        @xml.css('result[err_code]').first['err_code'],
        @response.params['error_code']
      )
    end

    def test_error_detail
      assert_equal(
        URI.decode(
          @xml.css('result[err_detail]').first['err_detail']
        ).encode(Encoding::UTF_8, Encoding::CP932),
        @response.params['error_detail']
      )
    end
  end

  class RecurringSuccessTest < self
    def setup
      @xml = fixture_xml('success.xml')
      stub_gateway(status: 200, body: @xml.to_s)

      @response = gateway.recurring(100, valid_credit_card, purchase_detail)
    end

    def test_success?
      assert @response.success?
    end

    def test_transaction_code
      assert_equal(
        @xml.css('result[trans_code]').first['trans_code'],
        @response.params['transaction_code']
      )
    end
  end

  module RecurringFailTest
    def setup
      @xml = fixture_xml('invalid_card_number.xml')
      stub_gateway(status: 200, body: @xml.to_s)

      @response = gateway.recurring(100, valid_credit_card, purchase_detail)
    end

    def test_success?
      assert @response.success?
    end

    def test_transaction_code
      assert_equal(
        @xml.css('result[trans_code]').first['trans_code'],
        @response.params['transaction_code']
      )
    end

    def test_error_code
      assert_equal(
        @xml.css('result[err_code]').first['err_code'],
        @response.params['error_code']
      )
    end

    def test_error_detail
      assert_equal(
        URI.decode(
          @xml.css('result[err_detail]').first['err_detail']
        ).encode(Encoding::UTF_8, Encoding::CP932),
        @response.params['error_detail']
      )
    end
  end

  class RecurringMissionCodeValidationTest < self
    def setup
      stub_gateway(status: 200, body: fixture_xml('success.xml').to_s)

      @detail = purchase_detail
    end

    def test_invalid_mission_code
      @detail[:mission_code] = ActiveMerchant::Billing::EpsilonGateway::MissionCode::PURCHASE

      assert_raises(ArgumentError) do
        gateway.recurring(100, valid_credit_card, @detail)
      end
    end

    def test_valid_mission_code
      @detail[:mission_code] = ActiveMerchant::Billing::EpsilonGateway::MissionCode::RECURRING_6

      gateway.recurring(100, valid_credit_card, @detail)

      pass
    end
  end

  class CancelRecurringTest < self
    def setup
      stub_gateway(status: 200, body: fixture_xml('success.xml').to_s, action: :cancel_recurring)

      @detail = purchase_detail
    end

    def test_cancel_recurring
      response = gateway.cancel_recurring(user_id: @detail[:user_id], item_code: @detail[:item_code])

      assert_equal true, response.success?
    end
  end

  class CancelRecurringFailTest < self
    def setup
      stub_gateway(status: 200, body: fixture_xml('cancel_recurring_fail.xml').to_s, action: :cancel_recurring)

      @detail = purchase_detail
    end

    def test_cancel_recurring
      response = gateway.cancel_recurring(user_id: @detail[:user_id], item_code: @detail[:item_code])

      assert_equal false, response.success?
    end
  end

  class RegisteredRecurringTest < self
    def setup
      stub_gateway(status: 200, body: fixture_xml('success.xml').to_s, action: :registered_recurring)

      @detail = purchase_detail
    end

    def test_registered_recurring
      response = gateway.registered_recurring(1000, @detail)

      assert_equal true, response.success?
    end
  end

  class RegisteredRecurringFailTest < self
  end
end
