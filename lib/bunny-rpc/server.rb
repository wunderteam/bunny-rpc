require 'active_support/concern'

module BunnyRPC
  module Server
    extend ActiveSupport::Concern

    module ClassMethods

      def start
        puts "Starting #{service_name}..."

        # enable confirmations and listen for returned messages
        channel.confirm_select
        exchange.on_return { |info| @return_info = info }

        # listen on the service queue
        service_queue.subscribe(:block => true) do |info, properties, payload|
          puts "Received message: #{payload}..."
          @return_info = nil
          process(info, properties, payload)
        end
      end

      def process(info, properties, payload)
        begin
          response = self.send(properties.type, JSON.parse(payload))
        rescue JSON::ParserError => e
          response = InvalidPayload
        rescue NoMethodError => e
          response = InvalidMethod
        end

        respond(response, properties.reply_to, properties.correlation_id)
      end

      def respond(response, reply_queue, correlation_id)
        exchange.publish(JSON.dump(response),
          routing_key:    reply_queue,
          correlation_id: correlation_id,
          mandatory:      true)

        confirmed = channel.wait_for_confirms
        handle_return if @return_info
      end

      def stop
        puts "Stopping #{service_name}..."
        self.channel.close
        puts "Stopped. [Channel Status: #{self.channel.status}]"
      end

      def handle_return
        puts "Still need to handle return!!! (rollback last action somehow)"
      end

      # [AMQP elements]
      def exchange
        @exchange ||= channel.default_exchange
      end

      def service_queue
        @service_queue ||= channel.queue(service_name, :auto_delete => true)
      end

      # [service name getter/setter]
      def service_name
        @service_name ||= self.name.split('::').last.downcase
      end

      def set_service_name(service_name)
        @service_name = service_name
      end

      # [service method accessor]
      def service_methods
        methods(false)
      end

      # [Bunny client accessors]
      def channel
        Channel.channel
      end

      def connection
        Channel.connection
      end

    end
  end
end
