# ActiveMerchant::Epsilon

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

### CreditCard Payment

```ruby
require 'active_merchant'

ActiveMerchant::Billing::Base.mode = :test

ActiveMerchant::Billing::EpsilonGateway.contract_code = 'YOUR_CONTRACT_CODE'

gateway = ActiveMerchant::Billing::EpsilonGateway.new

amount = 10000

credit_card = ActiveMerchant::Billing::CreditCard.new(
  first_name: 'TARO',
  last_name:  'YAMADA',
  number:     '4242424242424242',
  month:      '10',
  year:       Time.now.year + 1
)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUBMRE',
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

### Convenience Store Payment

```ruby
convenience_store = ActiveMerchant::Billing::ConvenienceStore.new(
  code:           ActiveMerchant::Billing::ConvenienceStore::Code::LAWSON,
  full_name_kana: 'ヤマダ タロウ',
  phone_nubmer:   '0312345678'
)

purchase_detail = {
  user_id:      'YOUR_APP_USER_IDENTIFIER',
  user_email:   'yamada-taro@example.com',
  item_code:    'ITEM001',
  item_name:    'Greate Product',
  order_number: 'UNIQUE ORDER NUBMRE',
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
