module BunnyRPC
  module Channel
    def self.connection
      @connection ||= Bunny.new(:automatically_recover => false)
      @connection.start unless @connection.status == :open
      @connection
    end

    def self.channel
      @channel ||= connection.create_channel
      @channel.open unless @channel.status == :open
      @channel
    end
  end
end
