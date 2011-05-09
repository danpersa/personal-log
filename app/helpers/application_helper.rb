module ApplicationHelper


  # return a title on a per-page basis
  def title
    base_title = "Remind me to live"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def logo
    image_tag("remindmetolive.png", :alt => "Remind me to live", :class => "round")
  end
  
  def pluralize_without_numbers(count, one, many)
    pluralize(count, one, many)[count.to_s.length + 1..pluralize(count, one, many).length]
  end
  
  def has_prev_page(page)
    return true unless page <= 1
  end
  
  def has_next_page(next_feed_item)
    return true unless next_feed_item.nil?
  end
  
  def get_page
    @page = params[:page].nil? ? 1 : params[:page].to_i
  end
  
  def pagination(collection, items_per_page)
    @page = get_page
    r = collection.offset((@page - 1) * items_per_page).limit(items_per_page + 1).all
    @has_prev_page = has_prev_page(@page)
    next_feed_item = r[items_per_page]
    r = r[0..items_per_page - 1]
    @has_next_page = has_next_page(next_feed_item)
    return r
  end
end
