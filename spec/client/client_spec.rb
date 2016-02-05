require 'spec_helper'

describe BunnyRPC::Client do
  it 'is a test spec' do
    expect(true).to eq(true)
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
