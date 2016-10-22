require_relative 'spec_helper'
require_relative 'helpers'
require 'scraper'
require 'scraper/list_page_handler'
require 'scraper/post_page_handler'
require 'scraper/processor'
require 'logger'

Thread.abort_on_exception = true

RSpec.describe 'Scraper integration test' do
  include Helpers
  let(:exchange) { double("Rabbitmqexchange", publish: nil) }
  let(:posts) { double("posts-repo", {create: nil, update: nil}) }

  it 'example 1' do
    allow(Spider).to receive(:new).and_return(Spider.new(Mechanize.new, time_between_requests: 0))
    #allow(exchange).to receive(:publish) { |*args| p args }

    pphandler = PostPageHandler.new(posts, exchange)
    lphandler = ListPageHandler.new(pphandler)
    processor = Processor.new(pphandler, lphandler)
    scraper = Scraper.new(processor)
    scraper.enq('http://www.foromtb.com/forums/btt-con-suspensi%C3%B3n-trasera.60/page-1', ListPageHandler)


    DatabaseCleaner.clean_with(:truncation) 
    VCR.use_cassette 'scrape_first_page' do
      scraper.start
      wait_until(10) { scraper.done? }
      sleep 0.2
      puts 'scraper done'
      sleep 1
    end

    # TODO each thread own logger
    
    #VCR.use_cassette 'scrape_second_page' do
      #scraper.enq('http://www.foromtb.com/forums/btt-con-suspensi%C3%B3n-trasera.60/page-2', ListPageHandler)
      #wait_until(40) { scraper.done? }
      #sleep 0.2
    #end

      #sleep 0.2
      #wait_until(40) { scraper.done? }

      expect(Post.all.size).to eq 20
      expect(Post.take.description).to_not be_nil
      expect(Post.take.title).to_not be_nil
      expect(Post.take.thread_id).to_not be_nil
      expect(Post.take.posted_at).to_not be_nil
  end
end


