require 'minitest/autorun'

require 'active_merchant'
require 'active_merchant/epsilon'

require 'dotenv'
require 'pry'
require 'tapp'

require 'webmock/minitest'

Dotenv.load

ActiveMerchant::Billing::Base.mode = :test

ActiveMerchant::Billing::EpsilonGateway.contract_code = ENV['CONTRACT_CODE']

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
      user_id:       "U#{Time.now.to_i}",
      user_email:    'yamada-taro@example.com',
      item_code:     'ITEM001',
      item_name:     'Greate Product',
      order_number:  "O#{Time.now.to_i}"
    }
  end

  def purchase_detail_for_registered
    {
      user_id:       "U#{Time.now.to_i}",
      user_email:    'yamada-taro@example.com',
      user_name:     'YAMADA TARO',
      item_code:     'ITEM001',
      item_name:     'Greate Product',
      order_number:  "O#{Time.now.to_i}",
      mission_code:   '6'
    }
  end

  def fixture_xml(filename, parse: true)
    xml = File.read("test/fixtures/#{filename}")

    parse ? Nokogiri.parse(xml.sub('x-sjis-cp932', 'CP932')) : xml
  end

  def stub_gateway(status: 200, body: nil, action: :purchase)
    endpoint = ActiveMerchant::Billing::EpsilonGateway.test_url
    path = ActiveMerchant::Billing::EpsilonGateway::PATHS[action]

    stub_request(:post, endpoint + path).to_return(
      status: status,
      body: body
    )
  end
end
