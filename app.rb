$: << File.expand_path(File.join(File.dirname(__FILE__), 'lib/')) 

require 'active_record'
require 'bunny'
require 'mongo'
require 'sinatra'
require 'thin'

require 'scraper'
require 'post_repo'
require 'scraper/processor'
require 'scraper/list_page_handler'
require 'scraper/post_page_handler'
require 'scraper/foromtb'
require 'logging'


    STDOUT.sync = true # Important!!!
    env = ENV['RACK_ENV'] || 'development'
    puts env
    ActiveRecord::Base.logger = Logger.new('db/debug.log')
    configuration = nil
    if env == 'development' or env == 'test'
      configuration = YAML::load(IO.read('db/database.yml'))
    else
      require 'pg'
      puts 'setting config'
      configuration = {'production' => {adapter: 'postgresql', 
                                        database: 'mtb-scrape', 
                                        username: 'mtb-scrape',
                                        host: 'localhost',
                                        pool: 5,
                                        password: ENV['DB_PASSWORD']}}
    end
    ActiveRecord::Base.establish_connection(configuration[env])

    #logger.new 'Going to connect to RMQ'
    conn = Bunny.new(ENV['RMQ'])
    begin
      puts "Connecting to RabbitMQ..."
      conn.start
    rescue StandardError => e
      puts "Failed to connect to RabbitMQ"
      puts e.message
      sleep 1
      retry
    end
    ch = conn.create_channel
    exchange = ch.fanout("posts")

    puts "Going to connect to Mongo"
    client = Mongo::Client.new([ENV['MONGO_ADDRESS']], database: 'scraper',
                                                       connect_timeout: 5)
    posts = PostRepo.new(client)

    pphandler = PostPageHandler.new(posts, exchange)
    lphandler = ListPageHandler.new(pphandler)
    processor = Processor.new(pphandler, lphandler)
    $scraper  = Scraper.new(processor)
    puts 'config done'

class Application < Sinatra::Base
  include Logging
  configure do
    set :logging, true
  end

  post '/scrape' do
    puts 'Receive get'
    urls = ForoMtb.build_urls({num_pages: 1}.merge(params))
    urls.each { |url, handler| $scraper.enq url, handler }
    puts 'starting scraper'
    $scraper.start unless $scraper.started?
  end

  # For testing
  get '/hi' do
    "hi"
  end
end

  #conn.close
