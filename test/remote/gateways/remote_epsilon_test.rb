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
end
