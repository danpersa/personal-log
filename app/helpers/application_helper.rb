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
end
