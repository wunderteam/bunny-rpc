module TestService
  include BunnyRPC::Server
  service_name 'test_service'

  def self.do_thing(number)
    number + number
  end

  def self.do_thing_with_exception(number)
    number + number
  end
end
