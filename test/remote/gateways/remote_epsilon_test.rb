require 'test_helper'

class RemoteEpsilonGatewayTest < MiniTest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGateway.new
  end

  def test_purchase_successful
    VCR.use_cassette(:purchase_successful) do
      if valid_credit_card.validate.empty?
        response = gateway.purchase(10000, valid_credit_card, purchase_detail)
      end

      assert_equal true, response.success?
      assert_equal false, response.params['three_d_secure']
      assert_empty response.params['acs_url']
      assert_empty response.params['pa_req']
    end
  end

  def test_purchase_with_verification_value_successful
    VCR.use_cassette(:purchase_with_verification_value) do
      if valid_credit_card_with_verification_value.validate.empty?
        response = gateway.purchase(10000, valid_credit_card_with_verification_value, purchase_detail)
      end

      assert_equal true, response.success?
    end
  end

  def test_installment_purchase_successful
    VCR.use_cassette(:installment_purchase_successful) do
      if valid_credit_card_with_verification_value.validate.empty?
        response = gateway.purchase(10000, valid_credit_card_with_verification_value, installment_purchase_detail)
      end

      assert_equal true, response.success?
    end
  end

  def test_revolving_purchase_successful
    VCR.use_cassette(:revolving_purchase_successful) do
      if valid_credit_card_with_verification_value.validate.empty?
        response = gateway.purchase(10000, valid_credit_card_with_verification_value, revolving_purchase_detail)
      end

      assert_equal true, response.success?
    end
  end

  def test_purchase_with_three_d_secure_card_successful
    VCR.use_cassette(:purchase_with_three_d_secure_card_successful) do
      if valid_three_d_secure_card.validate.empty?
        response = gateway.purchase(
          10000,
          valid_three_d_secure_card,
          purchase_detail.merge(three_d_secure_check_code: 1)
        )
      end

      assert_equal true, response.success?
      assert_equal true, response.params['three_d_secure']
      assert_match /\Ahttps?/, response.params['acs_url']
      refute_empty response.params['pa_req']
    end

    VCR.use_cassette(:autheticate_three_d_secure_card_successful) do
      response = gateway.authenticate(valid_three_d_secure_pa_res)
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

  def test_terminate_recurring
    VCR.use_cassette(:terminate_recurring_successful) do
      detail = purchase_detail
      response = gateway.recurring(10000, valid_credit_card, detail)
      assert_equal true, response.success?
      response = gateway.terminate_recurring(user_id: detail[:user_id])
      assert_equal true, response.success?
    end
  end

  def test_terminate_recurring_fail
    VCR.use_cassette(:terminate_recurring_fail) do
      detail = purchase_detail
      response = gateway.recurring(10000, valid_credit_card, detail)
      assert_equal true, response.success?
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.terminate_recurring(user_id: detail[:user_id] + 'wrong')
      end
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

  def test_token_verify_successful
    VCR.use_cassette(:token_verify_successful) do
      response = gateway.verify(tokenized_credit_card, purchase_detail_with_token)
      assert_equal true, response.success?
    end
  end

  def test_token_verify_failure
    # used token is invalid
    VCR.use_cassette(:token_verify_failure) do
      response = gateway.verify(tokenized_credit_card, purchase_detail_with_token)
      assert_equal false, response.success?
    end
  end

  def test_find_user_success
    VCR.use_cassette(:find_user_success) do
      response = gateway.find_user(user_id: "U1416470209")
      assert_equal true, response.success?
    end
  end

  def test_find_user_failure
    VCR.use_cassette(:find_user_failure) do
      response = gateway.find_user(user_id: "")
      assert_equal false, response.success?
    end
  end

  def test_registered_purchase_successful
    VCR.use_cassette(:registered_purchase_successful) do
      response = gateway.registered_purchase(10000, purchase_detail_for_registered)
      assert_equal true, response.success?
    end
  end

  def test_registered_purchase_fail
    VCR.use_cassette(:registered_purchase_fail) do
      invalid_purchase_detail = purchase_detail_for_registered
      invalid_purchase_detail[:user_id] = ''
      response = gateway.registered_purchase(10000, invalid_purchase_detail)
      assert_equal false, response.success?
    end
  end

  def test_change_recurring_amount_successful
    VCR.use_cassette(:change_recurring_amount_successful) do
      detail = purchase_detail
      response = gateway.recurring(10000, valid_credit_card, detail)
      assert_equal true, response.success?
      response = gateway.change_recurring_amount(new_item_price: 5000, user_id: detail[:user_id], item_code: detail[:item_code])
      assert_equal true, response.success?
    end
  end

  def test_change_recurring_amount_failure
    VCR.use_cassette(:change_recurring_amount_failure) do
      detail = purchase_detail
      response = gateway.recurring(10000, valid_credit_card, detail)
      assert_equal true, response.success?
      response = gateway.change_recurring_amount(new_item_price: 5000, user_id: detail[:user_id], item_code: 'invalid code')
      assert_equal false, response.success?
    end
  end

  def test_find_order_success
    VCR.use_cassette(:find_order_success) do
      detail = purchase_detail
      purchase_response = gateway.purchase(100, valid_credit_card, detail)
      assert_equal true, purchase_response.success?

      response = gateway.find_order(detail[:order_number])
      assert_equal true, response.success?

      assert_equal true, !response.params['state'].empty?
      assert_equal true, !response.params['payment_code'].empty?
      assert_equal true, !response.params['item_price'].empty?
    end
  end

  def test_find_order_failure
    VCR.use_cassette(:find_order_failure) do
      response = gateway.find_order('1234567890')
      assert_equal false, response.success?
    end
  end
end
