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
    end
  end

  def test_gmo_later_purchase_fail
  end
end
