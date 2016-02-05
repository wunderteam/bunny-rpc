require_relative 'bunny_rpc'

module MyServiceClient

  def self.client(timeout: 5)
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
