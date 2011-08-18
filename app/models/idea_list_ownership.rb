class IdeaListOwnership < ActiveRecord::Base
  attr_accessible :idea_id, :idea_list_id

  belongs_to :idea
  belongs_to :idea_list

  validates :idea_id, :presence => true
  validates :idea_list_id, :presence => true
  validate  :unique_relationship
  
  scope :with_idea_and_idea_list, lambda { |idea, idea_list| where('idea_list_ownerships.idea_id = :idea_id AND idea_list_ownerships.idea_list_id = :idea_list_id',
        :idea_id => idea, :idea_list_id => idea_list) }
  
  
  private
  
  def unique_relationship
     if not idea_id.nil? and not idea_list_id.nil? and (self.class.with_idea_and_idea_list(idea, idea_list).count > 0)
       errors.add(:idea, "must be unique")
       errors.add(:idea_list, "must be unique")
     end
  end
  
  def self.destroy_for_idea_of_user(idea, user)
    IdeaListOwnership.destroy_all("idea_list_ownerships.idea_id = :idea_id and idea_list_ownerships.idea_list.user_id = :user_id").joins(:idea_list)
  end
  
end
