module BunnyRPC
  class Error < StandardError
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
