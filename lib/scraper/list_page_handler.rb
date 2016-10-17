require_relative 'list_page'
require_relative '../post'
require_relative '../logging'

class ListPageHandler

  include Logging

  def initialize(post_page_handler)
    @post_page_handler = post_page_handler
  end

  def download_q=(queue)
    @download_queue = queue
  end

  def process_page(page)
    #logger.debug "LPHandler processing page #{page.uri}"
    page.extend ListPage
    page.posts.each { |post| eval_post(post) }
  end

  # eval_preview?
  def eval_post(post)
    db_post = get_post_from_db(post.thread_id)
    if db_post.nil? # new post?
      download(post)
    elsif title_changed?(post, db_post)
      if post.title.match(/(vendid|cerrad)/i)
        db_post.update!(closed: true, last_message_at: post.last_message_at) 
      else 
        download(post)
      end
    else 
      update_last_msg(post, db_post)
    end
  end

  def download(post)
    logger.debug "Queueing new url #{post.url}"
    @download_queue << [post.url, @post_page_handler.class] # tuple?
    # TODO distinguish between post and ppreview
    @post_page_handler.add_post_preview(post.url, post)
  end

  def get_post_from_db(thread_id)
    Post.find_by(thread_id: thread_id)
  end

  def title_changed?(post, db_post)
    post.title != db_post.title
  end

  def update_last_msg(post, db_post)
    unless db_post.last_message_at == post.last_message_at
      logger.debug 'updating last message...'
      db_post.update last_message_at: post.last_message_at
    end
  end
end
