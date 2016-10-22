require 'pry'
require 'rack'
require 'rack/test'
require_relative 'spec_helper'
require_relative 'helpers'

ENV['RACK_ENV'] = 'test'
ENV['SPIDER_DELAY'] = '0.1'
require_relative '../app'

RSpec.describe 'Integration test: scrape first page' do
  include Rack::Test::Methods
  include Helpers

  def app() Application end

  before(:all) do
    conn = Bunny.new(ENV['RMQ'])
    begin
      puts "Trying to connect to RabbitMQ"
      conn.start
      puts "Connected"
    rescue StandardError => e
      puts "Failed to connect to RabbitMQ"
      sleep 1
      retry
    end
    ch  = conn.create_channel
    x   = ch.fanout("posts")
    @q   = ch.queue("", :exclusive => true)
    @q.bind(x)

    @mongo = Mongo::Client.new([ENV['MONGO_ADDRESS']], database: 'scraper',
                                                       connect_timeout: 5)
    @mongo[:posts].delete_many
    raise "Posts still in DB" unless @mongo[:posts].count == 0
    DatabaseCleaner.clean_with(:truncation) 
    VCR.use_cassette 'scrape_first_page' do
      post '/scrape'
      wait_until(20) { @q.message_count >= 20 }
    end
  end

  it 'should publish posts' do
    expect(@q.message_count).to eq 20
    delivery_info, properties, payload = @q.pop
    expect(payload).to match /description/
    expect(properties[:type]).to eq 'create'
  end

  it 'should add posts to database' do # Mongo
    posts = @mongo[:posts]
    expect(posts.count).to eq 20
  end
end

