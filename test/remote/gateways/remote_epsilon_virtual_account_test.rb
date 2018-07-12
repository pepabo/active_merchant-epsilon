require 'test_helper'

class RemoteEpsilonVirtualAccountGatewayTest < MiniTest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonVirtualAccountGateway.new
  end

  def test_virtual_account_purchase_successfull
    VCR.use_cassette(:virtual_account_purchase_successful) do
      response = gateway.purchase(10000, purchase_detail)

      assert_equal true, response.success?
    end
  end

  def test_virtual_account_purchase_fail
  end
end