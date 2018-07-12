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

      assert_match /\A\d+\z/, response.params['transaction_code']

      assert_match /\A\d{7}\z/, response.params['account_number']
      assert_match /\A\S+\z/, response.params['account_name']
      assert_match /\A\d{4}\z/, response.params['bank_code']
      assert_match /\A\S+\z/, response.params['bank_name']
      assert_match /\A\d{3}\z/, response.params['branch_code']
      assert_match /\A\S+\z/, response.params['branch_name']
    end
  end

  def test_virtual_account_purchase_fail
    invalid_purchase_detail = purchase_detail
    invalid_purchase_detail[:user_id] = ''

    VCR.use_cassette(:virtual_account_purchase_fail) do
      response = gateway.purchase(10000, invalid_purchase_detail)
      assert_equal false, response.success?
    end
  end
end