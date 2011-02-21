class Reminder < ActiveRecord::Base
  
  belongs_to :micropost
  
  validates :reminder_date,  :presence => true
  validates :micropost_id, :presence => true
  
end
