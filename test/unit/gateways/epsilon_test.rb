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

    def test_raise_error
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class ForbiddenTest < self
    def setup
      stub_gateway(status: 403)
    end

    def test_raise_error
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class ServerErrorTest < self
    def setup
      stub_gateway(status: 500)
    end

    def test_raise_error
      assert_raises(ActiveMerchant::ResponseError) do
        gateway.purchase(100, valid_credit_card, purchase_detail)
      end
    end
  end

  class SuccessTest < self
    def setup
      @xml = Nokogiri.parse(File.read('test/fixtures/success.xml').sub('x-sjis-cp932', 'CP932'))
      stub_gateway(status: 200, body: @xml.to_s)

      @response = gateway.purchase(100, valid_credit_card, purchase_detail)
    end

    def test_success?
      assert @response.success?
    end

    def test_trans_code
      assert_equal @xml.css('result[trans_code]').first['trans_code'], @response.params['trans_code']
    end
  end
end
