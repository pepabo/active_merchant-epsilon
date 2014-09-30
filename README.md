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

gateway = ActiveMerchant::Billing::EpsilonGateway.new(
  contact_code: 'YOUR_CONTACT_CODE'
)

amount = 10000

credit_card = ActiveMerchant::Billing::CreditCard.new(
  first_name: 'TARO',
  last_name:  'YAMADA',
  number:     '4242424242424242',
  month:      '10',
  year:       Time.now.year+1
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

### Monthly Subscritpion(Recurring Billing)

```ruby
gateway.recurring(amount, creadit_card, purchase_detail)
```

## Contributing

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Commit your changes (`git commit -am 'Add some feature'`)
3. Push to the branch (`git push origin my-new-feature`)
4. Create a new Pull Request
