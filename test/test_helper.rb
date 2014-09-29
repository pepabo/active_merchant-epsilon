require 'minitest/autorun'

require 'active_merchant'
require 'active_merchant/epsilon'

require 'dotenv'
require 'pry'

require 'webmock/minitest'

Dotenv.load

ActiveMerchant::Billing::Base.mode = :test

module SampleCreditCardMethods
  def valid_credit_card
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '4242424242424242',
      month:      '10',
      year:       Time.now.year + 1
    )
  end

  def invalid_credit_card
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '0000000000000000',
      month:      '10',
      year:       Time.now.year + 1 ,
    )
  end

  def purchase_detail
    {
      user_id:      SecureRandom.hex(10),
      user_email:   'yamada-taro@example.com',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: 'UNIQUE ORDER NUBMRE',
    }
  end

  def stub_gateway(status: 200, body: nil)
    stub_request(:post, ActiveMerchant::Billing::EpsilonGateway.test_url).to_return(status: status)
  end
end
