require_relative 'bunny_rpc'

module MyService
  include BunnyRPC::Server
  service_name 'my_service'

  def self.do_thing(number)
    number + number
  end
end
