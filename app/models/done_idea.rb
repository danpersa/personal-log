class DoneIdea < ActiveRecord::Base
  
  attr_accessible :user, :idea
  
  belongs_to :user
  belongs_to :idea
  
  validates :user_id, :presence => true
  validates :idea_id, :presence => true
  
end
