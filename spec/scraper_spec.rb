#require_relative 'spec_helper'
require 'scraper'

RSpec.describe Scraper, loads_DB: true do
  describe '#start' do
    let(:spider) { double("spider").as_null_object }
    let(:processor) { double("processor").as_null_object }

    before { @scraper = Scraper.new(processor) }
    after  { @scraper.stop }

    it 'starts and runs an instance of spider' do
      expect(Spider).to receive(:new).and_return spider
      expect(spider).to receive(:crawl_async)
      @scraper.start
    end

    it 'runs processor' do
      expect(processor).to receive(:process_async)
      @scraper.start
    end
  end
  
  describe '#enq' do
  end
end
