require 'rack'
require 'rack/test'
require_relative 'spec_helper'
require_relative 'helpers'

ENV['RACK_ENV'] = 'test'
ENV['SPIDER_DELAY'] = '0.1'
require_relative '../app'

RSpec.describe 'Integration test' do
  include Rack::Test::Methods
  include Helpers

  def app() Application end

  before do
    conn = Bunny.new
    conn.start
    ch  = conn.create_channel
    x   = ch.fanout("posts")
    @q   = ch.queue("", :exclusive => true)
    @q.bind(x)
  end

  it 'should scrape requested pages' do
    DatabaseCleaner.clean_with(:truncation) 
    VCR.use_cassette 'scrape_first_page' do
      get '/scrape'
      messages = []
      sleep 1
      @q.subscribe(:block => false) do |delivery_info, properties, body|
        messages << body
      end
      wait_until(20) { messages.size >= 20 }
      expect(messages.first).to match /description/
    end
  end
end

