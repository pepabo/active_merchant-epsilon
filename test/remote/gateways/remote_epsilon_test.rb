require 'test_helper'

class RemoteEpsilonGatewayTest < MiniTest::Test
  include SampleCreditCardMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGateway.new
  end

  def setup
    WebMock.allow_net_connect!
  end

  def test_purchase_successful
    response = gateway.purchase(10000, valid_credit_card, purchase_detail)

    assert_equal true, response.success?
  end

  def test_purchase_fail
    response = gateway.purchase(10000, invalid_credit_card, purchase_detail)

    assert_equal false, response.success?
  end

  def test_recurring_successful
    response = gateway.recurring(10000, valid_credit_card, purchase_detail)

    assert_equal true, response.success?
  end

  def test_recurring_fail
    response = gateway.recurring(10000, invalid_credit_card, purchase_detail)

    assert_equal false, response.success?
  end

  def test_cancel_recurring
    detail = purchase_detail

    response = gateway.recurring(10000, valid_credit_card, detail)

    assert_equal true, response.success?

    response = gateway.cancel_recurring(user_id: detail[:user_id], item_code: detail[:item_code])

    assert_equal true, response.success?
  end

  def test_cancel_recurring_fail
    detail = purchase_detail

    response = gateway.recurring(10000, valid_credit_card, detail)

    assert_equal true, response.success?

    response = gateway.cancel_recurring(
      user_id: detail[:user_id],
      item_code: detail[:item_code] + 'wrong'
    )

    assert_equal false, response.success?
  end

  def test_void
    detail = purchase_detail

    purchase_response = gateway.purchase(100, valid_credit_card, detail)

    assert_equal true, purchase_response.success?

    response = gateway.void(detail[:order_number])

    assert_equal true, response.success?
  end

  def test_void_fail
    response = gateway.void('1234567890')

    assert_equal false, response.success?
  end
end
