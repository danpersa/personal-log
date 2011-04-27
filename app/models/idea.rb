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
  #, :reminders_attributes

  belongs_to :user
  has_many   :reminders, :dependent => :destroy
  #accepts_nested_attributes_for :reminders

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => 'ideas.created_at DESC'

  def public?
    # the idea is public if it has at least one public reminder
    public_privacy = Privacy.find_by_name("public")
    Reminder.from_idea_by_privacy(self, public_privacy).size > 0
  end
  
  #def self.from_users_followed_by(user)
  #  followed_ids = user.following.map(&:id).join(", ")
  #  where("user_id IN (#{followed_ids}) OR user_id = ?", user)
  #end
end
