# ActiveMerchant::Epsilon
[![Gem](https://img.shields.io/gem/v/active_merchant-epsilon.svg?style=flat-square)](https://rubygems.org/gems/active_merchant-epsilon)
[![Build Status](https://travis-ci.org/pepabo/active_merchant-epsilon.svg?branch=master)](https://travis-ci.org/pepabo/active_merchant-epsilon)

[Epsilon](http://www.epsilon.jp/) integration for ActiveMerchant.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_merchant-epsilon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_merchant-epsilon

## Usage

### Settings

An example Rails initializer would look something like this:

```ruby
ActiveMerchant::Billing::Base.mode = :production
ActiveMerchant::Billing::EpsilonGateway.contract_code = '12345678'
ActiveMerchant::Billing::EpsilonGateway.proxy_port = 8080
ActiveMerchant::Billing::EpsilonGateway.proxy_address = 'myproxy.dev'
```

### CreditCard Payment

```ruby
require 'active_merchant'

ActiveMerchant::Billing::Base.mode = :test

ActiveMerchant::Billing::EpsilonGateway.contract_code = 'YOUR_CONTRACT_CODE'

gateway = ActiveMerchant::Billing::EpsilonGateway.new

amount = 10000

ActiveMerchant::Billing::CreditCard.require_verification_value = true

credit_card = ActiveMerchant::Billing::CreditCard.new(
  first_name:         'TARO',
  last_name:          'YAMADA',
  number:             '4242424242424242',
  month:              '10',
  year:               Time.now.year + 1,
  verification_value: '000', # security code
)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_name:    '山田 太郎',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUMBER',
  memo1:        'memo1',
  memo2:        'memo2',
}

if credit_card.validate.empty?
  # Capture 10000 yen from the credit card
  response = gateway.purchase(amount, credit_card, purchase_detail)

  if response.success?
    puts "Successfully charged #{amount} yen to the credit card #{credit_card.display_number}"
  else
    raise StandardError, response.message
  end
end
```

### CreditCard Payment with 3D secure

```ruby
amount = 10000

ActiveMerchant::Billing::CreditCard.require_verification_value = true

credit_card = ActiveMerchant::Billing::CreditCard.new(
  first_name:         'TARO',
  last_name:          'YAMADA',
  number:             '4242424242424242',
  month:              '10',
  year:               Time.now.year + 1,
  verification_value: '000', # security code
)

purchase_detail = {
  user_id:                   'YOUR_APP_USER_IDENTIFIER',
  user_name:                 '山田 太郎',
  user_email:                'yamada-taro@example.com',
  item_code:                 'ITEM001',
  item_name:                 'Greate Product',
  order_number:              'UNIQUE ORDER NUMBER',
  three_d_secure_check_code: 1,
  memo1:                     'memo1',
  memo2:                     'memo2',
}

if credit_card.validate.empty?
  response = gateway.purchase(amount, credit_card, purchase_detail)

  raise StandardError, response.message unless response.success?

  if response.params['three_d_secure']
    puts response.params['acs_url']
    puts response.params['pareq']
  else
    # NOT 3D SECURE
    puts "Successfully charged #{amount} yen to the credit card #{credit_card.display_number}"
  end
end

# (The card holder identifies himself on credit card's page and comes back here)

# AND SECOND REQUEST

response = gateway.authenticate(
  order_number:         'ORDER NUMBER',
  three_d_secure_pares: 'PAYMENT AUTHENTICATION RESPONSE',
)

if response.success?
  puts "Successfully charged to the credit card"
else
  raise StandardError, response.message
end
```

### CreditCard Installment Payment

```ruby
# (snip)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_name:    '山田 太郎',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUMBER',
  credit_type:  ActiveMerchant::Billing::EpsilonGateway::CreditType::INSTALLMENT,
  payment_time: 3, # 3, 5, 6, 10, 12, 15, 18, 20, 24
  memo1:        'memo1',
  memo2:        'memo2',
}

# (snip)
```

### CreditCard Payment with 3D secure 2.0(with token)

```ruby
# 3D secure 2.0 does not have a test environment for epsilon
ActiveMerchant::Billing::Base.mode = :production

amount = 1000
purchase_detail = {
  user_id:                   'YOUR_APP_USER_IDENTIFIER',
  user_name:                 '山田 太郎',
  user_email:                'yamada-taro@example.com',
  item_code:                 'ITEM001',
  item_name:                 'Greate Product',
  order_number:              'UNIQUE ORDER NUMBER',
  three_d_secure_check_code: 1,
  token:                     'CREDIT CARD TOKEN'
  tds_flag:                  21 # 21 or 22
  # optional:
  #   add params for risk-based certification(billAddrCity etc...)
}

response = gateway.purchase(amount, ActiveMerchant::Billing::CreditCard.new, purchase_detail)

if response.success?
  if response.params['three_d_secure']
    puts response.params['tds2_url']
    puts response.params['pa_req']
  else
    # NOT 3D SECURE
    puts "Successfully charged #{amount} yen as credit card payment(not 3D secure)"
  end
else
  raise StandardError, response.message
end

# (The card holder identifies himself on credit card's page and comes back here)

# AND SECOND REQUEST

response = gateway.authenticate(
  order_number:         'ORDER NUMBER',
  three_d_secure_pares: 'PAYMENT AUTHENTICATION RESPONSE',
)

if response.success?
  puts 'Successfully charged as credit card payment(3D secure 2.0)'
else
  raise StandardError, response.message
end
```

### CreditCard Revolving Payment

```ruby
# (snip)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_name:    '山田 太郎',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUMBER',
  credit_type:  ActiveMerchant::Billing::EpsilonGateway::CreditType::REVOLVING,
  memo1:        'memo1',
  memo2:        'memo2',
}

# (snip)
```

### Convenience Store Payment

```ruby
ActiveMerchant::Billing::EpsilonConvenienceStoreGateway.contract_code = 'YOUR_CONTRACT_CODE'

gateway = ActiveMerchant::Billing::EpsilonConvenienceStoreGateway.new

convenience_store = ActiveMerchant::Billing::ConvenienceStore.new(
  code:           ActiveMerchant::Billing::ConvenienceStore::Code::LAWSON,
  full_name_kana: 'ヤマダ タロウ',
  phone_number:   '0312345678'
)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_name:    '山田 太郎',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUMBER',
  memo1:        'memo1',
  memo2:        'memo2',
}

if credit_card.validate.empty?
  # 10000 yen as convenience store paymet
  response = gateway.purchase(amount, convenience_store, purchase_detail)

  if response.success?
    puts "Successfully charged #{amount} yen as convenience store payment"
    puts "Receipt number is #{response.params['receipt_number']}"
    puts "Payment limit date is #{response.params['convenience_store_limit_date']}"
  else
    raise StandardError, response.message
  end
end
```

### Recurring Billing (Monthly subscriptions)

```ruby
purchase_detail[:mission_code] = ActiveMerchant::Billing::EpsilonGateway::MissionCode::RECURRING_6

gateway.recurring(amount, creadit_card, purchase_detail)
```

### Cancel recurring billing

```ruby
gateway.cancel_recurring(user_id: 'user_id', item_code: 'item_code')
```

### Void Transaction

```ruby
gateway.void('order_number')
```

### Verify Credit Card

```ruby
gateway.verify(credit_card, user_id: 'user_id', user_email: 'user@example.com')
```

### GMO ID Settlement

```ruby
ActiveMerchant::Billing::EpsilonGmoIdGateway.contract_code = 'YOUR_CONTRACT_CODE'

gateway = ActiveMerchant::Billing::EpsilonGmoIdGateway.new

amount = 10000

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_email:   'yamada-taro@example.com',
  user_name:    'YAMADA TARO',
  item_code:    'ITEM001',
  item_name:    'Golden Product',
  order_number: 'UNIQUE ORDER NUMBER',
  gmo_id:       'Your member id of GMO ID',
  gmo_card_id:  'Your sequential card number of GMO ID',
}

gateway.purchase(amount, purchase_detail)
```

### GMO ID Settlement Void Transaction

```ruby
gateway.void('order_number')
```

### Virtual Account Payment

```ruby
ActiveMerchant::Billing::EpsilonVirtualAccountGateway.contract_code = 'YOUR_CONTRACT_CODE'

gateway = ActiveMerchant::Billing::EpsilonVirtualAccountGateway.new

amount = 10000

purchase_detail = {
  user_id:        'YOUR_APP_USER_IDENTIFIER',
  user_name:      '山田 太郎',
  user_email:     'yamada-taro@example.com',
  item_code:      'ITEM001',
  item_name:      'Greate Product',
  order_number:   'UNIQUE ORDER NUMBER',
  user_name_kana: 'ﾔﾏﾀﾞﾀﾛｳ'
}

response = gateway.purchase(amount, purchase_detail)

if response.success?
  puts "Successfully charged #{amount} yen as virtual account payment"
  puts "Account number is #{response.params['account_number']}"
  puts "Bank name is #{response.params['account_name']}"
else
  raise StandardError, response.message
end
```

### Epsilon Link Payment

EpsilosLinkPaymentGateway is available in all link payments.
For example, GMO Payment After Delivery.

If you don't need to send paramaters of delivery information details(e.g. consignee_postal, consignee_name, orderer_postal, and orderer_name), you set `delivery_info_required` to `false`.

Default value of `delivery_info_required` is `true`, therefore you must set delivery information details to purchase_detail When you don't set `delivery_info_required`.

```ruby
ActiveMerchant::Billing::EpsilonLinkPaymentGateway.contract_code = 'YOUR_CONTRACT_CODE'

gateway = ActiveMerchant::Billing::EpsilonLinkPaymentGateway.new

amount = 10000

purchase_detail = {
  user_id:           'YOUR_APP_USER_IDENTIFIER',
  user_name:         '山田 太郎',
  user_email:        'yamada-taro@example.com',
  user_tel:          '0312345678',
  item_code:         'ITEM001',
  item_name:         'Greate Product',
  order_number:      'UNIQUE ORDER NUMBER',
  st_code:           'SETTLEMENT_CODE',
  consignee_postal:  '1500002',
  consignee_name:    '山田 太郎',
  consignee_address: '東京都渋谷区1-1-1',
  consignee_tel:     '0312345678',
  orderer_postal:    '1500002',
  orderer_name:      '山田 太郎',
  orderer_address:   '東京都渋谷区1-1-1',
  orderer_tel:       '0312345678',
  memo1:             'memo1',
  memo2:             'memo2',
}

delivery_info_required = true

response = gateway.purchase(amount, purchase_detail, delivery_info_required)

if response.success?
  puts "Successfully send order data"
  puts "Redirect url is #{response.params['redirect']}"
else
  raise StandardError, response.message
end
```

### Epsilon Link Payment Void Transaction
```ruby
gateway.void('order_number')
```

### Error handling

If epsilon server returns status excepted 200, `#purchase` method raise `ActiveMerchant::ResponseError`.

When your request parameters are wrong(e.g. contract_code), the method returns failure response.

- `#success?` returns `false`
- `#params` has error detail

```ruby
response = gateway.purchase(10000, creadit_card, invalid_detail)

response.success? # => false
response.params   # => Hash included error detail
```

## Contributing

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Commit your changes (`git commit -am 'Add some feature'`)
3. Push to the branch (`git push origin my-new-feature`)
4. Create a new Pull Request
