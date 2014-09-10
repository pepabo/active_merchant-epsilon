require 'test_helper'

class TestEpsilonGateway < MiniTest::Unit::TestCase
  def setup
    @gateway = ActiveMerchant::Billing::EpsilonGateway.new
  end

  def test_initialize
    assert @gateway
  end
end
