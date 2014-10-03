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
    response = gateway.recurring(10000, valid_credit_card, purchase_detail)

    assert_equal true, response.success?

    response = gateway.cancel_recurring(
      user_id: purchase_detail[:user_id],
      item_code: purchase_detail[:item_code]
    )

    assert_equal true, response.success?
  end
end
