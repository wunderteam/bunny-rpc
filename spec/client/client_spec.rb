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
  it 'is a test spec' do
    expect(true).to eq(true)
  end

  describe 'dispatches message to rpc client' do
    before { allow(MockClient.client).to receive(:dispatch){ true } }
    before { MockClient.do_thing('hello world') }

    it { expect(MockClient.client).to have_received(:dispatch).with(:do_thing, 'hello world') }
  end

  # describe 'moqueue' do
  #   let(:mq) { MQ.new }
  #   let(:queue) { queue = mq.queue('mocktacular') }
  #   before do
  #     topic = mq.topic("lolz")
  #     queue.bind(topic, :key=> "cats.*")
  #     queue.subscribe {|header, msg| puts [header.routing_key, msg]}
  #     topic.publish("eatin ur foodz", :key => "cats.inUrFridge")
  #   end
  #
  #   it { expect(queue.received_message?('eatin ur foodz')).to eq(true) }
  # end
end
