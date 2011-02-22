class Micropost < ActiveRecord::Base
  attr_accessible :content, :reminder_date

  belongs_to :user

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :reminder_date, :presence => true
  validates :user_id, :presence => true
  validate :reminder_date_cannot_be_in_the_past

  default_scope :order => 'microposts.created_at DESC'

  #def self.from_users_followed_by(user)
  #  followed_ids = user.following.map(&:id).join(", ")
  #  where("user_id IN (#{followed_ids}) OR user_id = ?", user)
  #end

  # Return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  def reminder_date_cannot_be_in_the_past
    errors.add(:reminder_date, "can't be in the past") if
      reminder_date != nil and reminder_date < Date.today
  end
  
  private
  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    where("user_id IN (#{followed_ids}) OR user_id = :user_id", { :user_id => user })
  end

end
