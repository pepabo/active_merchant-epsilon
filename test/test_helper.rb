require 'minitest/autorun'

require 'active_merchant'
require 'active_merchant/epsilon'

require 'dotenv'
require 'pry'
require 'tapp'
require 'vcr'

require 'webmock/minitest'
require 'mocha/minitest'

Dotenv.load

ActiveMerchant::Billing::Base.mode = :test

ActiveMerchant::Billing::EpsilonGateway.contract_code = ENV['CONTRACT_CODE']
ActiveMerchant::Billing::EpsilonGateway.proxy_address = ENV['PROXY_ADDRESS'] if ENV['PROXY_ADDRESS']
ActiveMerchant::Billing::EpsilonGateway.proxy_port    = ENV['PROXY_PORT'] if ENV['PROXY_PORT']

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('[CONTRACT_CODE]') { ENV['CONTRACT_CODE'] }
  c.filter_sensitive_data('[GMO_ID]') { ENV['GMO_ID'] }
  c.filter_sensitive_data('gmo_card_id=[GMO_CARD_ID]') { "gmo_card_id=#{ENV['GMO_CARD_ID']}" } # GMO CARD ID is not unique.
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

  def tokenized_credit_card
    ActiveMerchant::Billing::CreditCard.require_verification_value = false
    ActiveMerchant::Billing::CreditCard.new(
      first_name: 'TARO',
      last_name:  'YAMADA',
      number:     '',
      month:      '',
      year:       '',
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
      order_number: "O#{now.sec}#{now.usec}",
      memo1:        'memo1',
      memo2:        'memo2',
    }
  end

  def purchase_detail_with_token
    now = Time.now
    {
      user_id:      "U#{Time.now.to_i}",
      user_name:    'YAMADA Taro',
      user_email:   'yamada-taro@example.com',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{now.sec}#{now.usec}",
      token:        '4ee16d6784077b5c3c67605db2a06d8b8ef7e8325deb5ceb9794451da1bb8c5f',
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
      memo1:        'memo1',
      memo2:        'memo2',
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
      memo1:        'memo1',
      memo2:        'memo2',
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
      mission_code: '6',
      memo1:        'memo1',
      memo2:        'memo2',
    }
  end

  def purchase_detail_for_three_d_secure_2
    now = Time.now
    {
      user_id:                   "U#{now.to_i}",
      user_name:                 'YAMADA Taro',
      user_email:                'yamada-taro@example.com',
      item_code:                 'ITEM001',
      item_name:                 'Greate Product',
      order_number:              "O#{now.sec}#{now.usec}",
      token:                     '03d4a2ce2f747c9223a4ead24888d0293ad26c06273e296f9faa0675f99a1ff7',
      three_d_secure_check_code: 1,
      tds_flag:                  21,
    }
  end

  def purchase_detail_for_registered_and_three_d_secure_2
    {
      user_id:      'U1416470209',
      user_email:   'yamada-taro@example.com',
      user_name:    'YAMADA TARO',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{Time.now.to_i}",
      tds_flag:      21,
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

  def valid_gmo_id_purchase_detail
    {
      user_id:      "U#{Time.now.to_i}",
      user_email:   'yamada-taro@example.com',
      user_name:    'YAMADA TARO',
      item_code:    'ITEM001',
      item_name:    'Golden Product',
      order_number: "O#{Time.now.to_i}",
      gmo_id:       ENV['GMO_ID'],
      gmo_card_id:  ENV['GMO_CARD_ID'],
    }
  end

  def invalid_gmo_id_purchase_detail
    {
      user_id:      "U#{Time.now.to_i}",
      user_email:   'yamada-taro@example.com',
      user_name:    'YAMADA TARO',
      item_code:    'ITEM001',
      item_name:    'Golden Product',
      order_number: "O#{Time.now.to_i}",
      gmo_id:       ENV['GMO_ID'],
      gmo_card_id:  'invail id',
    }
  end

  def gmo_after_purchase_detail
    now = Time.now
    {
      user_id:      "U#{Time.now.to_i}",
      user_name:    '山田 太郎',
      user_email:   'yamada-taro@example.com',
      user_tel:     '0312345678',
      item_code:    'ITEM001',
      item_name:    'Greate Product',
      order_number: "O#{now.sec}#{now.usec}",
      st_code:      '00000-0000-00000-00010-00000-00000-00000',
      memo1:        'memo1',
      memo2:        'memo2',
      consignee_postal: '1000001',
      consignee_name: 'イプシロンタロウ',
      consignee_address: '東京都千代田区千代田1番1号',
      consignee_tel: '0312345678',
      orderer_postal: '1000001',
      orderer_name: 'YAMADA Taro',
      orderer_address: '東京都千代田区千代田1番1号',
      orderer_tel: '0312345678',
    }
  end

  def valid_epsilon_link_type_purchase_detail
    now = Time.now
    {
      user_id:       "U#{Time.now.to_i}",
      user_name:     '山田 太郎',
      user_email: 'yamada-taro@example.com',
      item_code:     'ITEM001',
      item_name:    'Greate Product',
      order_number:  "O#{now.sec}#{now.usec}",
      st_code:       '00000-0000-01000-00000-00000-00000-00000',
      memo1:         'memo1',
      memo2:         'memo2',
      consignee_postal: '1000001',
      consignee_name: 'イプシロンタロウ',
      consignee_address: '東京都千代田区千代田1番1号',
      consignee_tel: '0312345678',
      orderer_postal: '1000001',
      orderer_name: 'YAMADA Taro',
      orderer_address: '東京都千代田区千代田1番1号',
      orderer_tel: '0312345678',
    }
  end

  def valid_epsilon_link_type_not_sending_delivery_information_purchase_detail
    now = Time.now
    {
      user_id:       "U#{Time.now.to_i}",
      user_name:     '山田 太郎',
      user_email: 'yamada-taro@example.com',
      item_code:     'ITEM001',
      item_name:    'Greate Product',
      order_number:  "O#{now.sec}#{now.usec}",
      st_code:       '00000-0000-01000-00000-00000-00000-00000',
      memo1:         'memo1',
      memo2:         'memo2',
    }
  end

  def invalid_epsilon_link_type_purchase_detail
    now = Time.now
    {
      user_id:       "U#{Time.now.to_i}",
      user_name:     '山田 太郎',
      user_email: 'yamada-taro@example.com',
      item_code:     'ITEM001',
      item_name:    'Greate Product',
      order_number:  "O#{now.sec}#{now.usec}",
      st_code:       'invalid_id',
      memo1:         'memo1',
      memo2:         'memo2',
      consignee_postal: '1000001',
      consignee_name: 'イプシロンタロウ',
      consignee_address: '東京都千代田区千代田1番1号',
      consignee_tel: '0312345678',
      orderer_postal: '1000001',
      orderer_name: 'YAMADA Taro',
      orderer_address: '東京都千代田区千代田1番1号',
      orderer_tel: '0312345678',
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
