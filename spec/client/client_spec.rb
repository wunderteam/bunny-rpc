require 'spec_helper'

describe BunnyRPC::Client do
  let(:dummy_client) { instance_double('DummyClient') }

  before :all do
    thread = TestServiceMacros.start
  end

  after :all do
    thread = TestServiceMacros.stop
  end

  it 'is a test spec' do
    expect(true).to eq(true)
  end

  describe 'dispatches message to rpc client' do
    before do
      allow(TestClient).to receive(:client){ dummy_client }
      allow(dummy_client).to receive(:dispatch){ true }
    end
    before { TestClient.do_thing('hello world') }
    it { expect(dummy_client).to have_received(:dispatch).with(:do_thing, 'hello world') }
  end
end
