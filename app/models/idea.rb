# == Schema Information
# Schema version: 20110405072140
#
# Table name: ideas
#
#  id            :integer(4)      not null, primary key
#  content       :string(255)
#  user_id       :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  privacy_id    :integer(4)
#

class Idea < ActiveRecord::Base
  attr_accessible :content, :privacy, :privacy_id
  #, :reminders_attributes

  belongs_to :user
  belongs_to :privacy
  has_many   :reminders, :dependent => :destroy
  #accepts_nested_attributes_for :reminders

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true
  validates :privacy_id, :presence => true

  default_scope :order => 'ideas.created_at DESC'

  #def self.from_users_followed_by(user)
  #  followed_ids = user.following.map(&:id).join(", ")
  #  where("user_id IN (#{followed_ids}) OR user_id = ?", user)
  #end

  # Return ideas from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  scope :from_user_with_privacy, lambda { |user, logged_user| with_privacy(user, logged_user) }
  
  private
  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    public_privacy_id = Privacy.find_by_name("public").id
    where("(user_id IN (#{followed_ids} AND privacy_id = #{public_privacy_id})) OR user_id = :user_id", { :user_id => user })
  end
  
  def self.with_privacy(user, logged_user)
    if !logged_user.nil? and user == logged_user
      where("user_id = :user_id", { :user_id => user })
    elsif
      public_privacy_id = Privacy.find_by_name("public").id
      where("user_id = :user_id AND privacy_id = #{public_privacy_id}", { :user_id => user })
    end
  end

end
