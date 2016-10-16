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
  let(:posts) { double("Mongo-posts-collection", {insert_one: nil, update_one: nil}) }

  it 'example 1' do
    pphandler = PostPageHandler.new(posts, exchange)
    lphandler = ListPageHandler.new(pphandler)
    processor = Processor.new(pphandler, lphandler)
    scraper = Scraper.new(processor)
    scraper.enq('http://www.foromtb.com/forums/btt-con-suspensi%C3%B3n-trasera.60/page-1', ListPageHandler)
    allow(Spider).to receive(:new).and_return(Spider.new(Mechanize.new, time_between_requests: 0))

    VCR.use_cassette 'scrape_first_page' do
      scraper.start
      wait_until { scraper.done? }

      expect(Post.all.size).to eq 20
      expect(Post.take.description).to_not be_nil
      expect(Post.take.title).to_not be_nil
      expect(Post.take.thread_id).to_not be_nil
      expect(Post.take.posted_at).to_not be_nil
    end
  end
end


