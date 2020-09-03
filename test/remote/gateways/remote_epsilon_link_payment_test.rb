require 'test_helper'
class RemoteEpsilonLinkPaymentTest < MiniTest::Test
  include SamplePaymentMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonLinkPaymentGateway.new
  end

  def test_epsilon_link_type_purchase_successfull
    VCR.use_cassette(:epsilon_link_type_purchase_successfull) do
      response = gateway.purchase(10000, valid_epsilon_link_type_purchase_detail)

      assert_equal true, response.success?
      assert_equal true, !response.params['redirect'].empty?
    end
  end

  def test_epsilon_link_type_not_sending_delivery_information_purchase_successfull
    VCR.use_cassette(:epsilon_link_type_not_sending_delivery_information_purchase_successfull) do
      response = gateway.purchase(10000, valid_epsilon_link_type_not_sending_delivery_information_purchase_detail, false)

      assert_equal true, response.success?
      assert_equal true, !response.params['redirect'].empty?
    end
  end

  def test_epsilon_link_type_purchase_fail
    VCR.use_cassette(:epsilon_link_type_purchase_fail) do
      response = gateway.purchase(10000, invalid_epsilon_link_type_purchase_detail)

      assert_equal false, response.success?
      assert_equal true, response.params["error_detail"].valid_encoding?
    end
  end

  def test_epsilon_link_type_void_successfull
    VCR.use_cassette(:epsilon_link_type_void_successfull) do
      # あらかじめ課金済ステータスの受注がイプシロン側にないと取り消しができないため、課金済の受注をイプシロン側で作成しておいた。
      # ここでは void の引数として作成済の受注のorder_numberを渡している。
      # VCRのキャッシュを作成し直す場合は変更しないとエラーとなる。
      response = gateway.void('595213151')

      assert_equal true, response.success?
    end
  end

  def test_epsilon_link_type_void_fail
    VCR.use_cassette(:epsilon_link_type_void_fail) do
      response = gateway.void('invalid_order_number')

      assert_equal false, response.success?
      assert_equal true, response.params["error_detail"].valid_encoding?
    end
  end
end
