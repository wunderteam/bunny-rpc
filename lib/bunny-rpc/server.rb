require 'logger'
require 'active_support/concern'

module BunnyRPC
  module Server
    extend ActiveSupport::Concern

    module ClassMethods

      def start
        log.info "Starting #{service_queue_name}..."

        # enable confirmations and listen for returned messages
        channel.confirm_select
        exchange.on_return { |info| @return_info = info }

        # listen on the service queue
        service_queue.subscribe(:block => true) do |info, properties, payload|
          log.debug "Received message: #{payload}..."
          @responded    = false
          @return_info  = nil
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

        rpc_wrapper.call do
          respond(response, properties.reply_to, properties.correlation_id)
        end

        raise InvalidRPCWrapper unless @responded
      end

      def respond(response, reply_queue, correlation_id)
        @responded = true

        exchange.publish(JSON.dump(response),
          routing_key:    reply_queue,
          correlation_id: correlation_id,
          mandatory:      true)

        confirmed = channel.wait_for_confirms
        raise UndeliverableResponse, @return_info if @return_info
      end

      def stop
        log.debug "Stopping #{service_queue_name}..."
        self.channel.close
        log.info "Stopped. [Channel Status: #{self.channel.status}]"
      end

      # [RPC wrapper]
      def wrap_rpc(&block)
        @rpc_wrapper = block
      end

      def rpc_wrapper
        @rpc_wrapper ||= Proc.new{ |respond| respond.call }
      end

      # [AMQP elements]
      def exchange
        @exchange ||= channel.default_exchange
      end

      def service_queue
        @service_queue ||= channel.queue(service_queue_name, :auto_delete => true)
      end

      # [service queue name getter/setter]
      def service_name(name)
        @service_queue_name = name
      end

      def service_queue_name
        @service_queue_name ||= self.name.split('::').last.downcase
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

      # [logging]
      def logger(logger)
        @logger = logger
      end

      def log
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
