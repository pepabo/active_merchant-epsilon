require 'test_helper'

class RemoteEpsilonConvenienceStoreGatewayTest < MiniTest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonConvenienceStoreGateway.new
  end

  def test_convenience_store_purchase_successful
    VCR.use_cassette(:convenience_store_purchase_successful) do
      response = gateway.purchase(10000, valid_convenience_store, purchase_detail)

      assert_equal true, response.success?
      assert_match /\d{7}/, response.params['receipt_number']
      assert_match /\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}/, response.params['receipt_date']
      assert_match /\d{4}\-\d{2}\-\d{2}/, response.params['convenience_store_limit_date']
      assert_match %r!\Ahttp://.+!, response.params['convenience_store_payment_slip_url']
      assert_match /\d{5}/, response.params['company_code']
    end
  end

  def test_convenience_store_purchase_fail
    VCR.use_cassette(:convenience_store_purchase_fail) do
      response = gateway.purchase(10000, invalid_convenience_store, purchase_detail)
      assert_equal false, response.success?
      assert_equal true, response.params["error_detail"].valid_encoding?
    end
  end
end
