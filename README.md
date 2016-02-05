# Bunny RPC
A thin RPC client/server based on Bunny (RabbitMQ) and toolkit for quickly building micro services. This MVP implementation focuses on solving for synchronous execution.

## RPC Design Goals
  1. Set up a new services with as little conceptual overhead as possible
  2. Fault tolerant synchronous execution:
    - Client should gracefully handle unavailable services
    - Client should gracefully handle service timeouts
    - Server should gracefully handle undeliverable responses (and should allow for work to be rolled back in that event)
  3. Baked in instrumentation [todo]
  4. Baked in service discovery

## Service Design Goals
  1. Allow for rapid service development
  2. Automatic serialization / deserialization of objects passed in and returned. (Simply expose JSON via OpenStruct)
  3. Consistent exception passing

## Future Features
  - Extend for backgrounding work across services
  - Consider extending to support an event-based model