class Reminder < ActiveRecord::Base
  attr_accessible :reminder_date, :privacy, :privacy_id, :idea, :idea_id
  
  belongs_to :user
  belongs_to :privacy
  belongs_to :idea
  
  validates :reminder_date, :presence => true
  validates :user_id, :presence => true
  validates :idea_id, :presence => true
  validates :privacy_id, :presence => true
  validate  :reminder_date_cannot_be_in_the_past
  
  
  private
  
  def reminder_date_cannot_be_in_the_past
    errors.add(:reminder_date, "can't be in the past") if
      reminder_date != nil and reminder_date < Date.today
  end
end
