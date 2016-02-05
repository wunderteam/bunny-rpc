dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
puts "LOADING: #{File.join(dir, 'bunny-rpc')}"
require File.join(dir, 'bunny-rpc')

module MyService
  include BunnyRPC::Server
  service_name 'my_service'

  def self.do_thing(number)
    number + number
  end
end

begin
  MyService.start
rescue Interrupt => _
  MyService.stop
  exit(0)
end
