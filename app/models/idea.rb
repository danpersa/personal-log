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
  attr_accessible :content
  #attr_accessor :user_id
  #, :reminders_attributes

  belongs_to :user
  has_many   :reminders, :dependent => :destroy
  #accepts_nested_attributes_for :reminders

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  # default_scope :order => 'ideas.created_at DESC'
  
  scope :ideas_order, order('ideas.created_at DESC')
  
  scope :reminders_order, order('reminders.created_at DESC')
  
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  def public?
    # the idea is public if it has at least one public reminder
    public_privacy = Privacy.find_by_name("public")
    Reminder.from_idea_by_privacy(self, public_privacy).size > 0
  end
  
  def public_users(logged_user)
    User.users_with_public_or_own_reminders_for_idea(self, logged_user)
  end
  
  private
  
  def self.followed_by(user)
    followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    public_privacy_id = Privacy.public_privacy_id
    joins(:reminders).
    where("(reminders.user_id IN (#{followed_ids} AND reminders.privacy_id = #{public_privacy_id})) OR reminders.user_id = :user_id", { :user_id => user }).
    group('ideas.id, ideas.content, ideas.user_id, ideas.created_at, ideas.updated_at').order("max(reminders.created_at) DESC")
    #includes(:reminders => [ {:user => :profile }, :privacy]).
  end
end
