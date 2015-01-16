require 'test_helper'

class RemoteEpsilonGatewayTest < MiniTest::Test
  include SampleCreditCardMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGateway.new
  end

  def test_purchase_successful
    VCR.use_cassette(:purchase_successful) do
      response = gateway.purchase(10000, valid_credit_card, purchase_detail)
      assert_equal true, response.success?
    end
  end

  def test_purchase_fail
    VCR.use_cassette(:purchase_fail) do
      response = gateway.purchase(10000, invalid_credit_card, purchase_detail)
      assert_equal false, response.success?
    end
  end

  def test_recurring_successful
    VCR.use_cassette(:recurring_successful) do
      response = gateway.recurring(10000, valid_credit_card, purchase_detail)
      assert_equal true, response.success?
    end
  end

  def test_recurring_fail
    VCR.use_cassette(:recurring_fail) do
      response = gateway.recurring(10000, invalid_credit_card, purchase_detail)
      assert_equal false, response.success?
    end
  end

  def test_registered_recurring_successful
    VCR.use_cassette(:registered_recurring_successful) do
      response = gateway.registered_recurring(10000, purchase_detail_for_registered)

      assert_equal true, response.success?
    end
  end

  def test_registered_recurring_fail
    VCR.use_cassette(:registered_recurring_fail) do
      invalid_purchase_detail = purchase_detail_for_registered
      invalid_purchase_detail[:mission_code] = ''
      response = gateway.registered_recurring(10000, invalid_purchase_detail)



      assert_equal false, response.success?
    end
  end

  def test_cancel_recurring
    VCR.use_cassette(:cancel_recurring_successful) do
      detail = purchase_detail

      response = gateway.recurring(10000, valid_credit_card, detail)

      assert_equal true, response.success?

      response = gateway.cancel_recurring(user_id: detail[:user_id], item_code: detail[:item_code])

      assert_equal true, response.success?
    end
  end

  def test_cancel_recurring_fail
    VCR.use_cassette(:cancel_recurring_fail) do
      detail = purchase_detail

      response = gateway.recurring(10000, valid_credit_card, detail)

      assert_equal true, response.success?

      response = gateway.cancel_recurring(
        user_id: detail[:user_id],
        item_code: detail[:item_code] + 'wrong'
      )

      assert_equal false, response.success?
    end
  end

  def test_void
    VCR.use_cassette(:void_successful) do
      detail = purchase_detail

      purchase_response = gateway.purchase(100, valid_credit_card, detail)

      assert_equal true, purchase_response.success?

      response = gateway.void(detail[:order_number])

      assert_equal true, response.success?
    end
  end

  def test_void_fail
    VCR.use_cassette(:void_fail) do
      response = gateway.void('1234567890')
      assert_equal false, response.success?
    end
  end

  def test_verify
    VCR.use_cassette(:verify_successful) do
      response = gateway.verify(valid_credit_card, purchase_detail.slice(:user_id, :user_email))
      assert_equal true, response.success?
    end
  end

  def test_verify_fail
    VCR.use_cassette(:verify_fail) do
      response = gateway.verify(invalid_credit_card, purchase_detail.slice(:user_id, :user_email))
      assert_equal false, response.success?
    end
  end

  def test_convenience_store_purchase_successful
    VCR.use_cassette(:convenience_store_purchase_successful) do
      response = gateway.purchase(10000, valid_convenience_store, purchase_detail)

      assert_equal true, response.success?
      assert_match /\d{7}/, response.params['receipt_number']
      assert_match /\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}/, response.params['receipt_date']
      assert_match /\d{4}\-\d{2}\-\d{2}/, response.params['convenience_store_limit_date']
    end
  end

  def test_convenience_store_purchase_fail
    VCR.use_cassette(:convenience_store_purchase_fail) do
      response = gateway.purchase(10000, invalid_convenience_store, purchase_detail)
      assert_equal false, response.success?
    end
  end
end
