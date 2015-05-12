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
ActiveMerchant::Billing::EpsilonGateway.proxy_address = ENV['PROXY_ADDRESS'] if ENV['PROXY_ADDRESS']
ActiveMerchant::Billing::EpsilonGateway.proxy_port    = ENV['PROXY_PORT'] if ENV['PROXY_PORT']

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('[CONTRACT_CODE]') { ENV['CONTRACT_CODE'] }
end

module SamplePaymentMethods
  def valid_credit_card
    ActiveMerchant::Billing::CreditCard.require_verification_value = false
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '4242424242424242',
      month:      '10',
      year:       Time.now.year + 1,
    )
  end

  def valid_credit_card_with_verification_value
    ActiveMerchant::Billing::CreditCard.require_verification_value = true
    ActiveMerchant::Billing::CreditCard.new(
      first_name:         'TARO',
      last_name:          'YAMADA',
      number:             '4242424242424242',
      month:              '10',
      year:               Time.now.year + 1,
      verification_value: '000',
    )
  end

  def valid_three_d_secure_card
    ActiveMerchant::Billing::CreditCard.require_verification_value = false
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '4123451111111117',
      month:      '12',
      year:       '2023',
    )
  end

  def invalid_credit_card
    ActiveMerchant::Billing::CreditCard.require_verification_value = false
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '0000000000000000',
      month:      '10',
      year:       Time.now.year + 1,
    )
  end

  def purchase_detail
    now = Time.now
    {
      user_id:      "U#{Time.now.to_i}",
      user_name:    'YAMADA Taro',
      user_email:   'yamada-taro@example.com',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{now.sec}#{now.usec}"
    }
  end

  def installment_purchase_detail
    now = Time.now
    {
      user_id:      "U#{Time.now.to_i}",
      user_name:    'YAMADA Taro',
      user_email:   'yamada-taro@example.com',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{now.sec}#{now.usec}",
      credit_type:  ActiveMerchant::Billing::EpsilonGateway::CreditType::INSTALLMENT,
      payment_time: 3,
    }
  end

  def revolving_purchase_detail
    now = Time.now
    {
      user_id:      "U#{Time.now.to_i}",
      user_name:    'YAMADA Taro',
      user_email:   'yamada-taro@example.com',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{now.sec}#{now.usec}",
      credit_type:  ActiveMerchant::Billing::EpsilonGateway::CreditType::REVOLVING,
    }
  end

  def purchase_detail_for_registered
    {
      user_id:      "U1416470209",
      user_email:   'yamada-taro@example.com',
      user_name:    'YAMADA TARO',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{Time.now.to_i}",
      mission_code: '6'
    }
  end

  def valid_three_d_secure_pa_res
    now = Time.now
    {
      order_number:          "O#{now.sec}#{now.usec}",
      three_d_secure_pa_res: 'xxxxxxxxxxxxxxxx',
    }
  end

  def valid_convenience_store
    ActiveMerchant::Billing::ConvenienceStore.new(
      code:           ActiveMerchant::Billing::ConvenienceStore::Code::LAWSON,
      full_name_kana: 'ヤマダ タロウ',
      phone_number:   '0312345678'
    )
  end

  def invalid_convenience_store
    ActiveMerchant::Billing::ConvenienceStore.new(
      code:           ActiveMerchant::Billing::ConvenienceStore::Code::LAWSON,
      full_name_kana: 'ヤマダ タロウ',
      phone_number:   '0312345678901'
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
