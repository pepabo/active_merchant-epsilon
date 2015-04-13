require 'test_helper'

class EpsilonGatewayTest < MiniTest::Test

  def test_set_proxy_address_and_port
    ActiveMerchant::Billing::EpsilonGateway.proxy_address = 'http://myproxy.dev'
    ActiveMerchant::Billing::EpsilonGateway.proxy_port = 1234
    gateway = ActiveMerchant::Billing::EpsilonGateway.new
    assert_equal(gateway.proxy_address, 'http://myproxy.dev')
    assert_equal(gateway.proxy_port, 1234)
  end
end
