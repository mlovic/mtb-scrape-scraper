require 'logging'

class Processor
  include Logging

  def initialize(*handlers)
    @handlers = handlers
  end

  def process_async(pages_q, url_q)
    @handlers.each { |h| h.download_q = url_q }
    @thread = Thread.new do
      until pages_q.closed?
        (page, handler = pages_q.pop) or Thread.exit
        dispatch(page, handler)
      end
    end
  end

  def running?
    @thread&.alive?
  end

  private
    def dispatch(page, handler)
      target = match_handler(handler) or raise "Unknown handler! #{handler}"
      target.process_page(page)
    rescue StandardError => e
      logger.error "Error processing page from #{page.respond_to?(:uri) ? page.uri : '[Unknown URL]'}"
      logger.error e.message
    end

    def match_handler(handler)
      @handlers.find { |h| h.class == handler }
    end
end
