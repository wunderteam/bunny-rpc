require 'spec_helper'

describe BunnyRPC::Client do
  let(:client) { BunnyRPC::Client.new('test_client', timeout: 0.1) }
  before(:all) { TestServiceMacros.start }
  after(:all)  { TestServiceMacros.stop }

  describe 'exchange returns message' do
    it { expect(true).to eq(true) }
  end

  describe '#dispatch' do
    it { expect(true).to eq(true) }
  end
end
