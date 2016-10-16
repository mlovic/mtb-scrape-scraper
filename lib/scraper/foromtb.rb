require 'scraper/list_page_handler'
require 'uri'

module ForoMtb
  ROOT        = 'http://www.foromtb.com/'
  FOROMTB_URI = 'http://www.foromtb.com/forums/btt-con-suspensi%C3%B3n-trasera.60/'

  def self.build_urls(options)
    options[:offset] ||= 0
    page_range = get_page_range(options[:num_pages], options[:offset])
    page_range.map do |num|
      url = URI.join(FOROMTB_URI, "page-#{num}").to_s
      [url, ListPageHandler] # Use symbol instead of class reference? 
    end
  end

  def self.get_page_range(num_pages, offset)
    start_page = offset + 1
    end_page   = offset + num_pages
    (start_page..end_page)
  end
end

