require 'uri'
require 'mechanize'

require_relative 'scraper/spider'
require_relative 'logging'

class Scraper
  Thread.abort_on_exception = true
  include Logging

  def initialize(processor)
    @url_q   = Queue.new
    @pages_q = Queue.new
    @processor = processor
  end

  def start(options = {})
    #offset = options[:start_page] || 1
    # TODO handle errors in spider thread
    return false if started?
    @spider = Spider.new(Mechanize.new) # get rid of hardcoded limit
    @spider.crawl_async(url_q, pages_q) # Async. Starts thread and returns immediately.
    # TODO handle potential deadlock error. Sleep and retry?
    @processor_thread = Thread.new do
      processor.dispatch(*pages_q.pop) until url_q.empty? && 
                                             !@spider.waiting_for_response? 
    end

    logger.debug "Done. Closing queues..."
    return true
    #url_q.close # Triggers Spider thread to exit
    #pages_q.close 
  end

  def enq(url, handler)
    url_q << [url, handler]
  end

  def stop
    return false unless started?
    logger.info "Killing spider and processor threads..."
    @spider.kill
    @processor_thread.kill
  end
  
  def started?
    @processor_thread&.alive?
  end

  private
    attr_accessor :url_q, :pages_q, :processor
end
