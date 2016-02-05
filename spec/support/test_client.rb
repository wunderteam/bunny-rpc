module TestClient
  def self.client(timeout: 1)
    @client ||= BunnyRPC::Client.new('test_client', timeout: timeout)
  end

  # replace this with method missing
  def self.do_thing(argument)
    client.dispatch(:do_thing, argument)
  end
end
