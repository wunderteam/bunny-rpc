module BunnyRPC
  module Channel
    def self.foo
      'bar'
    end

    def self.connection
      @connection ||= Bunny.new(:automatically_recover => false)
      @connection.start if @connection.status != :open
      @connection
    end

    def self.channel
      @channel ||= connection.create_channel
    end
  end
end
