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

end
