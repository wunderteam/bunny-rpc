require 'thread'
require 'securerandom'

module BunnyRPC
  class Client

    # TODO: must be able to send multiple arguments
    def initialize(service_name, timeout: 2)
      @service_name = service_name
      @timeout      = timeout

      setup_return_listener
      reset_reply_queue
    end

    # Listen for messages returned by the exchange
    #   - a returned message indicates that the service is unavailable
    def setup_return_listener
      channel.confirm_select
      exchange.on_return { |info| @return_info = info }
    end

    # the reply queue is re-settable so that:
    #   - this client instance can be re-used if a request times out
    #   - when/if the server gets around to responding, its resposne message will be returned which
    #   indicates to the server that it should rollback its transaction
    # Note: AMQP will assign a unique channel name when an empty string is passed in
    def reset_reply_queue
      @reply_queue.delete if @reply_queue
      @reply_queue = channel.queue('', :exclusive => true, :auto_delete => true)

      @reply_queue.subscribe do |delivery_info, properties, payload|
        payload = self.parse_payload(payload)

        if properties[:correlation_id] == @correlation_id
          @response = payload
          @lock.synchronize{@condition.signal}
        end
      end
    end

    def dispatch(method_name, arguments)
      @response       = nil
      @return_info    = nil
      @correlation_id = SecureRandom.uuid

      publish(method_name, arguments)
      raise ServiceUnreachable if @return_info

      lock.synchronize { condition.wait(lock, @timeout) }
      timeout! if @response.nil?

      @response
    end

    def publish(method_name, arguments)
      exchange.publish(encode_payload(arguments),
        routing_key:      @service_name,
        type:             method_name,
        correlation_id:   @correlation_id,
        reply_to:         @reply_queue.name,
        mandatory:        true)

      channel.wait_for_confirms
    end

    def timeout!
      reset_reply_queue
      raise ServiceTimeout
    end

    # [parse / encode JSON]
    def encode_payload(payload)
      payload = payload.is_a?(Hash) ? payload : payload.as_json
      JSON.dump(payload)
    end

    def parse_payload(payload)
      RecursiveOpenStruct.new(JSON.parse(payload))
    end

    # [Flow control]
    def lock
      @lock ||= Mutex.new
    end

    def condition
      @condition ||= ConditionVariable.new
    end

    # [AMQP elements]
    def exchange
      @exchange ||= channel.default_exchange
    end

    def channel
      Channel.channel
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
