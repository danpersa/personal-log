class IdeaList < ActiveRecord::Base

  attr_accessible :name
  belongs_to :user
  
  validates :name, :presence => true, :length => { :maximum => 20 }
  validates :user_id, :presence => true
  
  scope :order_by_name, order('idea_lists.name')
  scope :owned_by, lambda { |user| where('idea_lists.user_id = :user_id', :user_id => user).order_by_name }
  
end
