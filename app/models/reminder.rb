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
  
  #default_scope :order => 'reminders.created_at DESC'
  
  # Return reminders from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  scope :from_user_with_privacy, lambda { |user, logged_user| with_privacy(user, logged_user) }
  scope :from_idea_by_privacy, lambda { |idea, privacy| from_idea_by_privacy(idea, privacy) }
  scope :from_idea_by_user, lambda { |idea, user| from_idea_by_user(idea, user) }
  scope :public_or_own_reminders_for_idea, lambda { |idea, user| public_or_own_reminders_for_idea(idea, user) }
  scope :newest_public_or_own_reminder_for_idea, lambda { |idea, user| Reminder.public_or_own_reminders_for_idea(idea, user).order("reminders.created_at DESC").limit(1) }
  scope :from_user, lambda { |user| where("reminders.user_id = :user_id", :user_id => user) }
  
  private
  
  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    public_privacy_id = Privacy.public_privacy_id
    where("(reminders.user_id IN (#{followed_ids} AND reminders.privacy_id = #{public_privacy_id})) OR reminders.user_id = :user_id", { :user_id => user }).includes(:idea).includes(:privacy).includes(:user => :profile)
  end
  
  # returns all the reminders an user can see
  # if the user is the owner, he can see all the reminders
  # else he can see only the public ones
  def self.with_privacy(user, logged_user)
    if !logged_user.nil? and user == logged_user
      where("reminders.user_id = :user_id", { :user_id => user }).includes(:idea).includes(:user => :profile).order("reminders.created_at DESC")
    elsif
      public_privacy_id = Privacy.public_privacy_id
      where("reminders.user_id = :user_id AND reminders.privacy_id = #{public_privacy_id}", { :user_id => user }).includes(:idea).includes(:user => :profile).order("reminders.created_at DESC")
    end
  end
  
  # returns all the reminders from a specified idea, that has a specified privacy
  def self.from_idea_by_privacy(idea, privacy)
    joins(:idea).where("ideas.id = :idea_id AND reminders.privacy_id = :privacy_id", :idea_id => idea, :privacy_id => privacy).order("reminders.created_at DESC")
  end
  
  def self.from_idea_by_user(idea, user)
    joins(:idea).where("ideas.id = :idea_id AND reminders.user_id = :user_id", :idea_id => idea, :user_id => user).order("reminders.created_at DESC")
  end
  
  def self.public_or_own_reminders_for_idea(idea, user)
    public_privacy = Privacy.public_privacy_id
    where("(reminders.idea_id = :idea_id AND (reminders.privacy_id = :privacy_id OR reminders.user_id = :user_id))",
      :idea_id => idea,
      :privacy_id => public_privacy,
      :user_id => user)
  end
  
  def self.destroy_reminders_of_user_for_idea(idea, user)
    Reminder.destroy_all("(reminders.idea_id = :idea_id and reminders.user_id = :user_id)", :idea_id => idea, :user_id => user)
  end
  
  def reminder_date_cannot_be_in_the_past
    errors.add(:reminder_date, "can't be in the past") if
      reminder_date != nil and reminder_date < Date.today
  end
end
