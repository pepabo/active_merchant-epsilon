require 'test_helper'

class EpsilonGatewayTest < MiniTest::Test
  include SampleCreditCardMethods

  def gateway
    @gateway ||= ActiveMerchant::Billing::EpsilonGateway.new(contact_code: 'Foo')
  end

  class NotFoundTest < self
    def setup
      stub_gateway(status: 404)
    end

    def test_success
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class ForbiddenTest < self
    def setup
      stub_gateway(status: 403)
    end

    def test_success
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class ServerErrorTest < self
    def setup
      stub_gateway(status: 500)
    end

    def test_success
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end
end
