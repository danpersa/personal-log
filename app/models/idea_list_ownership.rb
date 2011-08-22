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
    sql = "
           idea_list_ownerships.idea_id = #{idea.id} and idea_list_ownerships.idea_list_id in (
           select idea_lists.id from idea_lists where idea_lists.user_id = #{user.id})
    "
    IdeaListOwnership.destroy_all(sql)
  end
  
end
