require 'minitest/autorun'

require 'active_merchant'
require 'active_merchant/epsilon'

require 'dotenv'
require 'pry'
require 'tapp'
require 'vcr'

require 'webmock/minitest'

Dotenv.load

ActiveMerchant::Billing::Base.mode = :test

ActiveMerchant::Billing::EpsilonGateway.contract_code = ENV['CONTRACT_CODE']

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<CONTRACT_CODE>') { ENV['CONTRACT_CODE'] }
end

module SamplePaymentMethods
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
    now = Time.now
    {
      user_id:       "U#{Time.now.to_i}",
      user_email:    'yamada-taro@example.com',
      item_code:     'ITEM001',
      item_name:     'Greate Product',
      order_number:  "O#{now.sec}#{now.usec}"
    }
  end

  def purchase_detail_for_registered
    {
      user_id:       "U1416470209",
      user_email:    'yamada-taro@example.com',
      user_name:     'YAMADA TARO',
      item_code:     'ITEM001',
      item_name:     'Greate Product',
      order_number:  "O#{Time.now.to_i}",
      mission_code:   '6'
    }
  end

  def valid_convenience_store
    ActiveMerchant::Billing::ConvenienceStore.new(
      code:          ActiveMerchant::Billing::ConvenienceStore::LAWSON,
      fullname_kana: 'ヤマダ タロウ',
      phone_number:  '0312345678'
    )
  end

  def invalid_convenience_store
    ActiveMerchant::Billing::ConvenienceStore.new(
      code:          ActiveMerchant::Billing::ConvenienceStore::LAWSON,
      fullname_kana: 'ヤマダ タロウ',
      phone_number:  '0312345678901'
    )
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
