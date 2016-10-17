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
    logger.info "Starting spider..."
    @spider.crawl_async(url_q, pages_q) # Async. Starts thread and returns immediately.
    logger.info "Starting processor..."
    @processor.process_async(pages_q, url_q)
    # TODO handle potential deadlock error. Sleep and retry?
      #url_q.empty? && 
        #!@spider.waiting_for_response? 
    return true
  end

  def enq(url, handler)
    url_q << [url, handler]
  end
  
  def done?
    url_q.empty? && 
    pages_q.empty? &&
    @processor.waiting? &&
    @spider.waiting?
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
