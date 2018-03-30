require 'test_helper'

class RemoteEpsilonGmoIdGatewayTest < MiniTest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGmoIdGateway.new
  end

  def test_gmo_id_purchase_successful
    VCR.use_cassette(:gmo_id_purchase_successful) do
      detail = valid_gmo_id_purchase_detail
      response = gateway.purchase(200, detail)
      assert_equal true, response.success?
    end
  end

  def test_gmo_id_purchase_failure
    VCR.use_cassette(:gmo_id_purchase_failure) do
      detail = invalid_gmo_id_purchase_detail
      response = gateway.purchase(200, detail)
      assert_equal false, response.success?
    end
  end
end
