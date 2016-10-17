$: << File.expand_path(File.join(File.dirname(__FILE__), 'lib/')) 

require 'active_record'
require 'bunny'
require 'mongo'
require 'sinatra'

require 'scraper'
require 'scraper/processor'
require 'scraper/list_page_handler'
require 'scraper/post_page_handler'
require 'scraper/foromtb'


class Application < Sinatra::Base
  configure do
    env = ENV['RACK_ENV'] || 'development'
    ActiveRecord::Base.logger = Logger.new('db/debug.log')
    if env == 'development' || 'test'
      configuration = YAML::load(IO.read('db/database.yml'))
    else
      configuration = {adapter: 'postgresql', 
                       database: 'mtb-scrape', 
                       username: 'mtb-scrape',
                       password: ENV['DB_PASSWORD']}
    end
    ActiveRecord::Base.establish_connection(configuration[env])

    conn = Bunny.new
    conn.start
    ch = conn.create_channel
    exchange = ch.fanout("posts")

    client = Mongo::Client.new([ENV['MONGO_ADDRESS']], database: 'scraper')
    posts = client[:posts]

    pphandler = PostPageHandler.new(posts, exchange)
    lphandler = ListPageHandler.new(pphandler)
    processor = Processor.new(pphandler, lphandler)
    $scraper  = Scraper.new(processor)
  end

  get '/scrape' do
    puts 'Receive get'
    urls = ForoMtb.build_urls({num_pages: 1}.merge(params))
    urls.each { |url, handler| $scraper.enq url, handler }
    puts 'starting scraper'
    $scraper.start unless $scraper.started?
  end
end

  #conn.close
