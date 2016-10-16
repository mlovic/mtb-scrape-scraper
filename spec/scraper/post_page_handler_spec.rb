require 'json'
require 'spec_helper'
require 'scraper/post_page_handler'
#require_relative '../factories'
require 'scraper/post_preview'

RSpec.describe PostPageHandler, loads_DB: true do
  let(:posts)      { double("posts collection") }
  let(:exchange)   { double("posts exchange") }
  let(:pp_handler) { PostPageHandler.new(posts, exchange) }
  let(:page)       { double("page") }
  let(:preview)    { double("preview") }

  describe '#process_page' do
    before do
      pp_handler.add_post_preview("url1", preview)
      allow(preview).to receive(:all_attrs).and_return preview_attr: 1
      allow(page).to receive(:all_attrs).and_return page_attr: 2
      #@post_attrs = {
    end

    context 'when post is already in database' do
      it 'updates post in database' do
        expect(posts).to receive(:update_one).with preview_attr: 1,
                                                   page_attr: 2
        pp_handler.process_page
      end

      it 'publishes update to exchange' do
        payload = JSON.generate({preview_attr: 1, page_attr: 2})
        expect(exchange).to receive(:publish).with(payload, type: 'update')
        pp_handler.process_page
      end
    end

    context 'when post not already in database' do
      it 'creates post in database' do
        expect(posts).to receive(:insert_one).with preview_attr: 1,
                                                   page_attr: 2
      end
      it 'publishes create to exchange' do
        payload = JSON.generate({preview_attr: 1, page_attr: 2})
        expect(exchange).to receive(:publish).with(payload, type: 'create')
        pp_handler.process_page
      end

    end
  end
end
