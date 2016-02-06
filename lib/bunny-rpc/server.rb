require 'active_support/concern'

module BunnyRPC
  module Server
    extend ActiveSupport::Concern

    module ClassMethods

      def start
        log.info "Starting #{service_queue_name}..."
        setup_return_listener
        setup_queue_listener
      end

      # listen on the service queue for RPC calls
      #   - message processing and response is called from within the rpc wrapper which enables the
      #   caller to place any activity within a transaction such that it can be rolled back if an
      #   exception occurs anywhere along the process chain
      def setup_queue_listener
        service_queue.subscribe(:block => true) do |info, properties, payload|
          log.debug "Received message: #{payload}..."
          @return_info = nil
          rpc_wrapper.call { process(info, properties, payload) }
        end
      end

      # Listen for messages returned by the exchange
      #   - a returned message indicates that the caller is no longer listening for the response.
      #   This could be the result of a caller fault or a timeout.
      #   - because the exception is throwin within the rpc_wrapper block, it will propogate up and
      #   can be used to rollback transactions
      def setup_return_listener
        channel.confirm_select
        exchange.on_return { |info| @return_info = info }
      end

      # Process RPC calls
      #   - payload is expected to be JSON encoded
      #   - service responses must be either a Hash or an object that responds to as_json
      def process(info, properties, payload)
        begin
          response = self.send(properties.type, parse_payload(payload))
        rescue JSON::ParserError => e
          response = InvalidPayload.new
        rescue NoMethodError => e
          response = InvalidMethod.new
        end

        respond(response, properties.reply_to, properties.correlation_id)
        raise UndeliverableResponse if @return_info
      end

      # Encapsulates the RPC response step. Endeavour to publish the response to the caller.
      #   - the response value must be a hash or must respond to as_json
      #   - use channel.wait_for_confirms to ensure that the response successfully lands on a queue
      #   - if the response message is returned by the exchange, the return listener will throw an
      #   exception before wait_for_confirms unblocks
      def respond(response, reply_queue, correlation_id)
        exchange.publish(encode_payload(response),
          routing_key:    reply_queue,
          correlation_id: correlation_id,
          mandatory:      true)

        channel.wait_for_confirms
      end

      def stop
        log.debug "Stopping #{service_queue_name}..."
        channel.close
        log.info "Stopped. [Channel Status: #{channel.status}]"
      end

      # [parse / encode JSON]
      def encode_payload(payload)
        payload = payload.is_a?(Hash) ? payload : payload.as_json
        JSON.dump(payload)
      end

      def parse_payload(payload)
        RecursiveOpenStruct.new(JSON.parse(payload))
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
