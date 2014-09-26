require 'test_helper'

describe ActiveMerchant::Billing::EpsilonGateway do
  let(:credit_card) {
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '4242424242424242',
      month:      '10',
      year:       Time.now.year + 1
    )
  }

  let(:invalid_credit_card) {
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '0000000000000000',
      month:      '10',
      year:       Time.now.year + 1 ,
    )
  }

  let(:detail) {
    {
      contract_code: ENV['CONTRACT_CODE'],
      user_id:       'YOUR_APP_USER_IDENTIFIER',
      user_email:    'yamada-taro@example.com',
      item_code:     'ITEM001',
      item_name:     'Greate Product',
      order_number:  rand(1000000),
    }
  }

  let(:amount) { 10000 }

  let(:gateway) { ActiveMerchant::Billing::EpsilonGateway.new }

  before do
    WebMock.allow_net_connect!
  end

  describe '#purchase' do
    describe 'valid creadit_card' do
      subject { gateway.purchase(amount, credit_card, detail) }

      it 'success' do
        subject.must_be :success?
      end

      it 'has trans_code' do
        subject.params['trans_code'].wont_be :empty?
      end
    end

    describe 'invalid creadit_card' do
      subject { gateway.purchase(amount, invalid_credit_card, detail) }

      it 'fail' do
        subject.wont_be :success?
      end

      it 'has trans_code' do
        subject.params['trans_code'].wont_be :empty?
      end
    end
  end
end
