require 'active_support/concern'

module BunnyRPC
  module Server
    extend ActiveSupport::Concern

    module ClassMethods

      def start
        @service_name ||= self.name.split('::').last.downcase
        puts "Starting #{@service_name}..."

        @exchange = channel.default_exchange
        channel.confirm_select                              # < enable confirmation
        @exchange.on_return { |info| @return_info = info }  # < watch for underliverable messages

        service_methods.each { |method| configure_queue(method) }
      end

      def stop
        puts "Stopping #{@service_name}..."
        self.channel.close
        puts "Stopped. [Channel Status: #{self.channel.status}]"
      end

      def configure_queue(queue_name)
        @queue = channel.queue("#{@service_name}.#{queue_name}", :auto_delete => true)

        @queue.subscribe(:block => true) do |delivery_info, properties, payload|
          @return_info = nil
          response = self.send(properties.type, payload)

          puts "Publishing response: #{response}.."
          @exchange.publish(response,
            routing_key: properties.reply_to,
            correlation_id: properties.correlation_id,
            mandatory: true)

          confirmed = channel.wait_for_confirms
          handle_return if @return_info
        end
      end

      def handle_return
        puts "Still need to handle return!!! (rollback last action somehow)"
      end

      def service_name(service_name)
        @service_name = service_name
      end

      def service_methods
        methods(false)
      end

      def channel
        Channel.channel
      end

      def connection
        Channel.connection
      end

    end
  end
end
