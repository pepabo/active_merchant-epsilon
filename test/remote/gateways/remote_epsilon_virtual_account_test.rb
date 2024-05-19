require 'test_helper'

class RemoteEpsilonVirtualAccountGatewayTest < Minitest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonVirtualAccountGateway.new
  end

  def test_virtual_account_purchase_successfull
    VCR.use_cassette(:virtual_account_purchase_successful) do
      response = gateway.purchase(10000, purchase_detail)

      assert_equal true, response.success?

      assert_equal true, !response.params['transaction_code'].empty?

      assert_equal true, !response.params['account_number'].empty?
      assert_equal true, !response.params['account_name'].empty?
      assert_equal true, !response.params['bank_code'].empty?
      assert_equal true, !response.params['bank_name'].empty?
      assert_equal true, !response.params['branch_code'].empty?
      assert_equal true, !response.params['branch_name'].empty?
    end
  end

  def test_virtual_account_purchase_fail
    invalid_purchase_detail = purchase_detail
    invalid_purchase_detail[:user_id] = ''

    VCR.use_cassette(:virtual_account_purchase_fail) do
      response = gateway.purchase(10000, invalid_purchase_detail)
      assert_equal false, response.success?
      assert_equal true, response.params["error_detail"].valid_encoding?
    end
  end
end
