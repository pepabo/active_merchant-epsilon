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

credit_card = ActiveMerchant::Billing::CreditCard.new(
  first_name: 'TARO',
  last_name: 'YAMADA',
  number: '4242424242424242',
  month: '10',
  year: Time.now.year+1
)

# Epsilon Gateway accepts all amount as Integer in 銭
amount = 100_00 # 100 yen

if credit_card.validate.empty?
  # Capture 100 yen from the credit card
  response = gateway.purchase(100_00, credit_card)

  if response.success?
    puts "Successfully charged #{amount / 100} yen to the credit card #{credit_card.display_number}"
  else
    raise StandardError, response.message
  end
end

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_merchant-epsilon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
