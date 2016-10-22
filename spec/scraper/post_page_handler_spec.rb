require 'json'
require 'spec_helper'
require 'scraper/post_page_handler'
require_relative '../factories'
require 'scraper/post_preview'
require 'uri'

RSpec.describe PostPageHandler, loads_DB: true do
  let(:posts)      { double("posts collection", {create: nil, update: nil}) }
  let(:exchange)   { double("posts exchange", publish: nil) }
  let(:pp_handler) { PostPageHandler.new(posts, exchange) }
  let(:page)       { double("page", uri: URI.parse('/uri/path')) }
  let(:preview)    { double("preview") }

  describe '#process_page' do
    before do
      pp_handler.add_post_preview("uri/path", preview)
      allow(preview).to receive(:all_attrs).and_return preview_attr: 1
      allow(page).to receive(:all_attrs).and_return page_attr: 2
      allow(Post).to receive(:create!).and_return double(id: nil)
      #@post_attrs = {
    end
    context 'when post preview is not in cache' do
      it 'logs a warning' do
      end
    end

    context 'when post is already in database' do
      let(:post) { build(:post) }
      before do 
        allow(Post).to receive(:find_by).and_return post
        allow(post).to receive(:update)
      end
      it 'updates post in database' do
        #pending
        expect(posts).to receive(:update).with preview_attr: 1,
                                                   page_attr: 2
        pp_handler.process_page(page)
      end

      it 'publishes update to exchange' do
        payload = JSON.generate({page_attr: 2, preview_attr: 1})
        expect(exchange).to receive(:publish).with(payload, type: 'update')
        pp_handler.process_page(page)
      end
    end

    context 'when post not already in database' do
      it 'creates post in database' do
        #pending
        expect(posts).to receive(:create).with preview_attr: 1,
                                                   page_attr: 2
        pp_handler.process_page(page)
      end

      it 'publishes create to exchange' do
        payload = JSON.generate({page_attr: 2, preview_attr: 1})
        expect(exchange).to receive(:publish).with(payload, type: 'create')
        pp_handler.process_page(page)
      end

    end
  end
end
