class IdeaList < ActiveRecord::Base

  attr_accessible :name
  belongs_to :user
  has_many   :idea_list_ownerships, :dependent => :destroy
  has_many   :ideas, :through => :idea_list_ownerships
  
  validates :name, :presence => true, :length => { :maximum => 20 }
  validates :user_id, :presence => true
  validate  :unique_name_per_user
  
  scope :order_by_name, order('idea_lists.name')
  scope :owned_by, lambda { |user| where('idea_lists.user_id = :user_id', :user_id => user).order_by_name }
  scope :with_name, lambda { |name| where('idea_lists.name = :name', :name => name) }
  
  
  private
  
  def unique_name_per_user
    errors.add(:name, "must be unique") if
      not name.nil? and (self.class.owned_by(user).with_name(name).count > 0)
  end
  
end
