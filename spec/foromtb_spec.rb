require 'scraper/foromtb'

RSpec.describe ForoMtb do

  describe '.build_urls' do

    it 'builds them correctly' do
      params = { num_pages: 2, offset: 2}
      urls = ForoMtb.build_urls params
      expect(urls.map { |url, _| url.to_s }).to eq \
        ["http://www.foromtb.com/forums/btt-con-suspensi%C3%B3n-trasera.60/page-3",
         "http://www.foromtb.com/forums/btt-con-suspensi%C3%B3n-trasera.60/page-4"]
    end

    it 'offset defaults to 0' do
      urls = ForoMtb.build_urls num_pages: 1
      expect(urls.size).to eq 1
      expect(urls.first.first.to_s).to match /page-1/
    end
  end
end
