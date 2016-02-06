module BunnyRPC
  class Error < StandardError
    def as_json
      { message: "It's an error!", code: 303 }
    end
  end

  class InvalidPayload < Error
  end

  class InvalidMethod < Error
  end

  class InvalidRPCWrapper < Error
  end

  class UndeliverableResponse < Error
  end

  class ServiceUnreachable < Error
  end

  class ServiceTimeout < Error
  end
end
