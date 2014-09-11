require 'minitest/autorun'

require 'active_merchant'
require 'active_merchant/epsilon'

require 'dotenv'
require 'pry'

Dotenv.load

ActiveMerchant::Billing::Base.mode = :test
