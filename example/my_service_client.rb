dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'bunny-rpc')

module MyServiceClient
  def self.client(timeout: 3)
    @client ||= BunnyRPC::Client.new('my_service', timeout: timeout)
  end

  # replace this with method missing
  def self.do_thing(argument)
    client.dispatch(:do_thing, argument)
  end

  def self.bogus_method(argument)
    client.dispatch(:bogus_method, argument)
  end
end

# response = MyServiceClient.bogus_method(number: 14)
response = MyServiceClient.do_thing(number: 14)
puts "Check it out: #{response}"
