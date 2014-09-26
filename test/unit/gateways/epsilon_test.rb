require 'test_helper'

class EpsilonGatewayTest < MiniTest::Test
  include SampleCreditCardMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGateway.new(contact_code: 'Foo')
  end

  class NotFoundTest < self
    def setup
      return_404
    end

    def test_success
      assert_raises(ActiveMerchant::ResponseError, 'Failed with 404') do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end
end
