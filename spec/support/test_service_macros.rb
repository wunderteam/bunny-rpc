# interface for starting and stopping a service instance
module TestServiceMacros
  def self.start
    @thread = Thread.new do
      at_exit { TestService.stop }
      TestService.start
    end
  end

  def self.stop
    @thread.exit
  end
end
