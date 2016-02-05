require 'bunny'

module BunnyRPC
  module Channel
    def self.connection
      @@connection ||= Bunny.new(:automatically_recover => false).start
    end

    def self.channel
      @@channel ||= connection.create_channel
    end
  end
end
