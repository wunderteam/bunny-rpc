dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'bunny-rpc')

module MyService
  include BunnyRPC::Server
  set_service_name 'my_service'

  def self.do_thing(object)
    value = object['number'] * 10
    { foo: value }
  end

end

begin
  MyService.start
rescue Interrupt => _
  MyService.stop
  exit(0)
end
