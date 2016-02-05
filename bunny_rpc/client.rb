require 'thread'
require 'securerandom'
require 'active_support/core_ext/object/try'

module BunnyRPC
  class Client
    attr_reader :service_name, :consumer, :timeout
    attr_reader :lock, :condition
    attr_accessor :response, :correlation_id, :reply_queue, :return_info

    def initialize(service_name, timeout: 2)
      @exchange     = channel.default_exchange
      @service_name = service_name
      @lock         = Mutex.new
      @condition    = ConditionVariable.new
      @timeout      = timeout

      channel.confirm_select                                  # < enable confirmation
      @exchange.on_return { |info| self.return_info = info }  # < watch for underliverable messages
      reset_reply_queue                                       # < configure the reply queue
    end

    def dispatch(method_name, argument)
      self.response       = nil
      self.return_info    = nil
      self.correlation_id = SecureRandom.uuid

      @exchange.publish(argument,
        routing_key:      "#{service_name}.#{method_name}",
        type:             method_name,
        correlation_id:   correlation_id,
        reply_to:         reply_queue.name,
        mandatory:        true
      )

      channel.wait_for_confirms
      handle_return if return_info

      lock.synchronize { condition.wait(lock, @timeout) }
      handle_timeout if response.nil?

      response
    end

    def handle_return
      case return_info.try(:reply_code)
      when 312
        raise "Undeliverable!"
      else
        raise "Unknown Error: #{return_info}"
      end
    end

    def handle_timeout
      reset_reply_queue
      raise "TIMEOUT!!"
    end

    # the reply queue is re-settable so that:
    #   - this client instance can be re-used if a request times out
    #   - when/if the server gets around to responding, its resposne message will be returned which
    #   indicates to the server that it should rollback its transaction
    # Note: AMQP will assign a unique channel name when an empty string is passed in
    def reset_reply_queue
      self.reply_queue.delete if @reply_queue
      self.reply_queue = channel.queue('', :exclusive => true, :auto_delete => true)

      self.reply_queue.subscribe do |delivery_info, properties, payload|
        if properties[:correlation_id] == self.correlation_id
          self.response = payload
          self.lock.synchronize{self.condition.signal}
        end
      end
    end

    def channel
      Channel.channel
    end
  end
end
