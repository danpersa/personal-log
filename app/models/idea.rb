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
  
  attr_accessible :content, :idea_list_tokens
  #attr_accessor :user_id
  #, :reminders_attributes
  attr_reader :idea_list_tokens

  belongs_to :user
  has_many   :reminders, :dependent => :destroy
  has_many   :good_ideas, :dependent => :destroy
  has_many   :done_ideas, :dependent => :destroy
  has_many   :idea_list_ownerships, :dependent => :destroy
  has_many   :idea_lists, :through => :idea_list_ownerships
  has_many   :users_considering_idea_good,
             :through => :good_ideas,
             :class_name => "User",
             :source => :user
  has_many   :users_who_marked_idea_as_done,
             :through => :done_ideas,
             :class_name => "User",
             :source => :user

  #accepts_nested_attributes_for :reminders

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  # default_scope :order => 'ideas.created_at DESC'
  
  scope :ideas_order, order('ideas.created_at DESC')
  
  scope :reminders_order, order('reminders.created_at DESC')
  
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  scope :owned_by, lambda { |user| where('ideas.user_id = :user_id', :user_id => user).ideas_order }
  
  scope :contained_in_list, lambda { |idea_list| where('exists (select * from idea_list_ownerships ilo where ilo.idea_list_id = :idea_list_id and ilo.idea_id = ideas.id)', :idea_list_id => idea_list) }

  scope :shared_with_other_users, lambda { where('exists(select * from reminders where reminders.user_id != ideas.user_id and reminders.idea_id = ideas.id)') }

  # the idea is public if it has at least one public reminder
  def public?
    public_privacy = Privacy.find_by_name("public")
    Reminder.from_idea_by_privacy(self, public_privacy).size > 0
  end
  
  # returns true if the specified user has at least one reminder for the
  # current idea
  def shared_by?(user)
    Reminder.from_idea_by_user(self, user).size > 0
  end
  
  def shared_with_other_users?
    Reminder.reminders_of_other_users_for_idea(self).size > 0
  end
  
  def donate_to_community!
    community_user = User.find_by_name("community")
    self.user_id = community_user.id
    self.save!
  end
  
  # returns the list of users that have public reminders for the current idea,
  # including the specified user if he has a public or private reminder for the
  # current idea
  def public_users(logged_user)
    User.users_with_public_or_own_reminders_for_idea(self, logged_user)
  end
  
  def idea_list_tokens=(ids)
    self.idea_list_ids = ids.split(",")
  end
  
  def self.destroy_ideas_of(user)
    # we should delete ideas that have no reminders
    # associated with them
    # also we should delete all public ideas that are not shared
    # with other users
    Idea.destroy_all("ideas.user_id = #{user.id} and not exists(select * from reminders where reminders.user_id != #{user.id} and reminders.idea_id = ideas.id)")
  end
  
  def self.donate_to_community_the_ideas_of(user)
    community_user_id = User.find_by_name("community").id
    with_scope(:find => where(:user_id => user.id)) do
      update_all(:user_id => community_user_id)
    end
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
