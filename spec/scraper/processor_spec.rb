require 'scraper/processor'
require_relative '../helpers'

Thread.abort_on_exception = true

RSpec.describe Processor do
  include Helpers
  HandlerClass = 'handler class'
  let(:handler) { double("handler", {'download_q=': nil , process_page: nil, class: HandlerClass}) }
  let(:processor) { Processor.new(handler) }
  let(:pages_q) { Queue.new }
  let(:download_q) { Queue.new }
  before do
    allow(handler).to receive(:class).and_return HandlerClass
  end

  describe '#crawl_async' do
    it 'dispatches each page to a handler' 
    it 'raises error when handler is not found'
    it 'consumes pages queue until closed' do
      pages_q << [1,  HandlerClass]
      processor.process_async(pages_q, download_q)
      wait_until { pages_q.empty? }
      pages_q << [1,  HandlerClass] 
      wait_until { pages_q.empty? }
      expect(processor).to be_running

      pages_q.close
      wait_until { !processor.running? }
      expect(processor).to_not be_running
    end

    it 'kills thread when pages queue closes' do
    end

    context 'Exception is raised' do
      it 'logs error'
      it 'continues with next item from the queue' do
        pages_q.push(["good page", HandlerClass])
               .push(["bad page",  HandlerClass])
               .push(["good page", HandlerClass])
        allow(handler).to receive(:process_page).with("good url").and_return("success")
        allow(handler).to receive(:process_page).with("bad page").and_raise("error!")

        expect(handler).to receive(:process_page).thrice
        processor.process_async(pages_q, download_q)
        wait_until { pages_q.empty? }
        pages_q.close
      end
    end
    
  end
end
