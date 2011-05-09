#exemple: <%= will_paginate(@feed_items, :renderer => MinimalPaginationLinkRenderer %>
# http://thewebfellas.com/blog/2010/8/22/revisited-roll-your-own-pagination-links-with-will_paginate-and-rails-3/
class MinimalPaginationLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  
  def container_attributes
    super.except(:first_label, :last_label)
  end

  protected

    def pagination
      [:previous_page, :next_page]
    end

end