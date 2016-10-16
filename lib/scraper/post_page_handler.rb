require_relative 'post_page'
require_relative '../post'
require_relative '../logging'

class PostPageHandler

  include Logging

  def initialize(posts, exchange)
    @posts = posts
    @exchange = exchange
    @previews = {} # previews_cache?
  end

  def download_q=(queue)
    @download_queue = queue
  end

  def process_page(page)
    attrs = get_post_data(page, page.uri.path.sub(/^\//, ''))
    process_post_data(attrs)
  end

  def add_post_preview(url, preview)
    @previews[url] = preview
    #store.enqueue
  end

  def get_post_data(page, url)
    # TODO page should carry url
    page.extend PostPage
    post_preview = @previews[url] or raise "Post preview was not found in cache!"
    @previews.delete(url)
    # TODO need to remove from hash? Hash best structure?
    attrs = page.all_attrs.merge(post_preview.all_attrs)
  end

  def process_post_data(attrs)
    if db_post = Post.find_by(thread_id: attrs[:thread_id])
      update_post(attrs, db_post)
    else
      create_post(attrs)
    end
  end

  def update_post(attrs, db_post) 
    # TODO keep title if vendida
    #if db_post.title == attrs[title]

    # TODO report the changes
    db_post.update(attrs)
    logger.info "Post #{db_post.id} updated - #{attrs[:title]}"
  end

  def create_post(attrs)
    new_post = Post.create!(attrs)
    logger.info "Post #{new_post.id} created - #{attrs[:title]}"
  end
end
