$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "bunny-rpc/version"

Gem::Specification.new do |s|
  s.name        = 'bunny-rpc'
  s.version     = BunnyRPC::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Dave Riess']
  s.email       = ['daveriess@gmail.com']
  s.homepage    = 'https://github.com/wunderteam/bunny-rpc'
  s.summary     = 'A toolkit for microservices over RabbitMQ'
  s.description = 'A toolkit for microservices over RabbitMQ'

  s.required_ruby_version = '>= 2.2.0'
  s.add_dependency 'json'
  s.add_dependency 'bunny',           "~> 2.2"
  s.add_dependency 'logger'
  s.add_dependency 'activesupport',   ">= 4.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
