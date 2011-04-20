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
  
  default_scope :order => 'reminders.created_at DESC'
  
  # Return reminders from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  scope :from_user_with_privacy, lambda { |user, logged_user| with_privacy(user, logged_user) }
  
  private
  
  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    public_privacy_id = Privacy.find_by_name("public").id
    where("(user_id IN (#{followed_ids} AND privacy_id = #{public_privacy_id})) OR user_id = :user_id", { :user_id => user })
    .includes(:idea)
    .includes(:privacy)
    .includes(:user => :profile)
  end
  
  def self.with_privacy(user, logged_user)
    if !logged_user.nil? and user == logged_user
      where("user_id = :user_id", { :user_id => user })
    elsif
      public_privacy_id = Privacy.find_by_name("public").id
      where("user_id = :user_id AND privacy_id = #{public_privacy_id}", { :user_id => user })
    end
  end
  
  def reminder_date_cannot_be_in_the_past
    errors.add(:reminder_date, "can't be in the past") if
      reminder_date != nil and reminder_date < Date.today
  end
end