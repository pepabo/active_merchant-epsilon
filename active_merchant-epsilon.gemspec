# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_merchant/epsilon/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_merchant-epsilon'
  spec.version       = ActiveMerchant::Epsilon::VERSION
  spec.authors       = ['Kenichi TAKAHASHI']
  spec.email         = ['kenichi.taka@gmail.com']
  spec.summary       = %q{Epsilon integration for ActiveMerchant.}
  spec.description   = %q{Epsilon integration for ActiveMerchant.}
  spec.homepage      = 'http://github.com/pepabo/active_merchant-epsilon'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activemerchant', '~> 1.48.0'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'tapp'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'mocha'
end
