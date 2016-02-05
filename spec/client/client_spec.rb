require 'spec_helper'

module MockClient
  def self.client(timeout: 1)
    @client ||= BunnyRPC::Client.new('my_service', timeout: timeout)
  end

  # replace this with method missing
  def self.do_thing(argument)
    client.dispatch(:do_thing, argument)
  end
end

describe MockClient do
  before :all do
    thread = TestServiceMacros.start
  end

  after :all do
    thread = TestServiceMacros.stop
  end

  it 'is a test spec' do
    expect(true).to eq(true)
  end

  # describe 'dispatches message to rpc client' do
  #   before { allow(MockClient.client).to receive(:dispatch){ true } }
  #   before { MockClient.do_thing('hello world') }
  #
  #   it { expect(MockClient.client).to have_received(:dispatch).with(:do_thing, 'hello world') }
  # end
end
