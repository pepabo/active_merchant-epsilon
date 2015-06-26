# ActiveMerchant::Epsilon
[![Gem](https://img.shields.io/gem/v/active_merchant-epsilon.svg?style=flat-square)](https://rubygems.org/gems/active_merchant-epsilon)
[![wercker status](https://app.wercker.com/status/43c6648e20f325c8c0a560c36e89781c/s/master "wercker status")](https://app.wercker.com/project/bykey/43c6648e20f325c8c0a560c36e89781c)

Epsilon integration for ActiveMerchant.

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
}

# (snip)
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
  phone_nubmer:   '0312345678'
)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_name:    '山田 太郎',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUMBER',
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

### Recurring Billing (Monthly subscritpion)

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

### Error handling

If epsilon server returns status excepted 200, `#purchase` method raise `ActiveMerchant::ResponseError`.

When your request parameters are wrong(e.g. contract_code), the method return failuer response.

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
