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
  
  def errors_for_field(object, field)
    html = String.new
    html << "<div id='#{object.class.name.underscore.downcase}_#{field}_errors' class='errors'>\n"
    unless object.errors.blank?
      html << "\t\t<ul>\n"
      object.errors[field].each do |error|
        html << "\t\t\t<li>#{error}</li>\n" 
      end
      html << "\t\t</ul>\n"
    end
    html << "\t</div>\n"
    return html.html_safe
  end
  
  def remote?
    if (@remote == true)
      return true
    end 
    return false
  end
  
  def hide_buttons?
    if (not @hide_buttons.nil?) and (@hide_buttons == true)
      return true
    end 
    false
  end
  
  def submit_button_name
    if (@submit_button_name.blank?)
      return "Post"
    end
    @submit_button_name
  end
  
  def respond_with_remote_form
    respond_to do |format|
      format.html
      format.js {
        @hide_buttons = true
        @remote = true 
      }
    end
  end
  
  def file_exists?(path)
    if (not path.blank?) and FileTest.exists?("#{RAILS_ROOT}/#{path}")
      return true
    end
    false
  end
end
