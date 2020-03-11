require 'test_helper'

class RemoteEpsilonGmoLaterGatewayTest < MiniTest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGmoLaterGateway.new
  end

  def test_gmo_later_purchase_successfull
    VCR.use_cassette(:gmo_later_purchase_successful) do
      response = gateway.purchase(10000, gmo_later_purchase_detail)

      assert_equal true, response.success?
      assert_equal true, !response.params['redirect'].empty?
    end
  end

  def test_gmo_later_purchase_fail
    invalid_purchase_detail = gmo_later_purchase_detail
    invalid_purchase_detail[:user_id] = ''

    VCR.use_cassette(:gmo_later_purchase_fail) do
      response = gateway.purchase(10000, invalid_purchase_detail)

      assert_equal false, response.success?
    end
  end
end
