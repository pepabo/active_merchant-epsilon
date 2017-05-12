require 'test_helper'

class EpsilonGatewayTest < MiniTest::Test
  include SamplePaymentMethods

  def test_set_proxy_address_and_port
    ActiveMerchant::Billing::EpsilonGateway.proxy_address = 'http://myproxy.dev'
    ActiveMerchant::Billing::EpsilonGateway.proxy_port = 1234
    gateway = ActiveMerchant::Billing::EpsilonGateway.new
    assert_equal(gateway.proxy_address, 'http://myproxy.dev')
    assert_equal(gateway.proxy_port, 1234)
  end

  def test_purchase_post_data_encoding_eucjp
    ActiveMerchant::Billing::EpsilonBaseGateway.encoding = Encoding::EUC_JP
    gateway = ActiveMerchant::Billing::EpsilonGateway.new
    fixture = YAML.load_file('test/fixtures/vcr_cassettes/purchase_successful.yml')
    response_body = fixture['http_interactions'][0]['response']['body']['string']
    detail = {
      user_name: '山田太郎',
      item_name: 'すごい商品',
      order_number: '12345678',
      memo1: '予備1',
      memo2: '予備2',
    }
    gateway.expects(:ssl_post).with(
      instance_of(String),
      all_of(
        includes('user_name=%BB%B3%C5%C4%C2%C0%CF%BA'),
        includes('item_name=%A4%B9%A4%B4%A4%A4%BE%A6%C9%CA'),
        includes('order_number=12345678'),
        includes('memo1=%CD%BD%C8%F71'),
        includes('memo2=%CD%BD%C8%F72'),
      )
    ).returns(response_body)
    gateway.purchase(100, valid_credit_card, detail)
  end
end
