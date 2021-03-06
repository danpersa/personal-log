# == Schema Information
# Schema version: 20110405072140
#
# Table name: users
#
#  id                          :integer(4)      not null, primary key
#  name                        :string(255)
#  email                       :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#  encrypted_password          :string(255)
#  salt                        :string(255)
#  admin                       :boolean(1)
#  state                       :string(255)     default("pending")
#  activation_code             :string(40)
#  activated_at                :datetime
#  password_reset_code         :string(40)
#  reset_password_mail_sent_at :datetime
#
require 'validators/email_format_validator'

class User < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessor :password, :updating_password
  attr_accessible :name, :email, :password, :password_confirmation, 
    :activation_code

  has_many :ideas
  has_many :idea_lists, :dependent => :destroy
  has_many :reminders, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id",
    :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed

  has_many :reverse_relationships, :foreign_key => "followed_id",
    :class_name => "Relationship",
    :dependent => :destroy

  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  has_one :profile, :dependent => :destroy
  
  has_many   :good_ideas, :dependent => :destroy
  has_many   :done_ideas, :dependent => :destroy
  has_many   :ideas_marked_as_good,
    :through => :good_ideas,
    :class_name => "Idea",
    :source => :idea
  has_many   :ideas_marked_as_done,
    :through => :done_ideas,
    :class_name => "Idea",
    :source => :idea         

  validates :name,  :presence     => true,
    :length       => { :maximum => 50 } 
  validates :email, :presence     => true,
    :email_format => true,
    :uniqueness   => { :case_sensitive => false },
    :length       => { :maximum => 255 }
  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
    :confirmation => true,
    :length       => { :within => 6..40 },
    :if           => :should_validate_password?
  
  validates_inclusion_of :state, :in => %w(pending active blocked),
    :message => "%{value} is not a valid state"

  before_save :encrypt_password
  before_create :make_activation_code
  before_destroy :destroy_ideas_of_user, :donate_ideas_to_community
  
  scope :users_with_public_or_own_reminders_for_idea, lambda { |idea, user| users_with_public_or_own_reminders_for_idea(idea, user) }
  scope :user_has_public_or_own_reminders_for_idea, lambda { |idea, user| user_has_public_or_own_reminders_for_idea(idea, user) }

  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil? or user.state == "blocked" 
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def marked_as_good?(idea)
    good_ideas.find_by_idea_id(idea)
  end
  
  def mark_as_good!(idea)
    good_ideas.create!(:idea => idea)
  end
  
  def unmark_as_good!(idea)
    good_ideas.find_by_idea_id(idea).destroy
  end
  
  def marked_as_done?(idea)
    done_ideas.find_by_idea_id(idea)
  end
  
  def mark_as_done!(idea)
    done_ideas.create!(:idea => idea)
  end
  
  def unmark_as_done!(idea)
    done_ideas.find_by_idea_id(idea).destroy
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def feed
    # Reminder.from_users_followed_by(self)
    Idea.from_users_followed_by(self)
  end
  
  def ideas_for_logged_user(logged_user)
    Idea.from_user_with_privacy(self, logged_user)
  end
  
  def reminders_for_logged_user(logged_user)
    Reminder.from_user_with_privacy(self, logged_user)
  end
  
  def activated?
    if self.activated_at == nil
      return false
    end
    return true
  end
  
  def reset_password_expired?
    return self.reset_password_mail_sent_at < 1.day.ago 
  end
  
  def reset_password
    self.password_reset_code = generate_token
    self.reset_password_mail_sent_at = Time.now.utc
    self.save!
    # we send the reset password mail
    UserMailer.reset_password(self).deliver
  end
  
  state_machine do
    state :pending # first one is initial state
    state :active
    state :blocked # the user in this state can't sign in

    event :activate do
      transitions :to => :active,
        :from => [:pending],
        :on_transition => :do_activate
    end
    
    event :block do
      transitions :to => :blocked,
        :from => [:pending, :active]
    end
  end

  def do_activate
    self.activated_at = Time.now.utc
    self.save!
  end
  
  def display_name
    unless self.profile.nil?
      unless self.profile.name.empty?
        return self.profile.name
      end
    end
    return self.name
  end
  
  def self.users_with_public_or_own_reminders_for_idea(idea, user)
    public_privacy = Privacy.public_privacy_id
    joins(:reminders).
      where("(reminders.idea_id = :idea_id AND (reminders.privacy_id = :privacy_id OR reminders.user_id = :user_id))",
      :idea_id => idea,
      :privacy_id => public_privacy,
      :user_id => user).
      group("users.id, users.name, users.email, users.salt, users.encrypted_password, users.activation_code, users.activated_at, users.state, users.admin, users.created_at, users.updated_at, users.password_reset_code, users.reset_password_mail_sent_at").
      order("max(reminders.created_at) ASC")
  end

  private
  
  def destroy_ideas_of_user
    Idea.destroy_ideas_of(self)
  end
  
  def donate_ideas_to_community
    Idea.donate_to_community_the_ideas_of(self)
  end

  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password) if should_validate_password?
  end

  def encrypt(s)
    secure_hash("#{salt}--#{s}")
  end

  def make_salt
    begin
      salt = secure_hash("#{Time.now.utc}--#{password}--#{SecureRandom.urlsafe_base64}")
    end while User.exists?(:salt => salt)
    return salt
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
  
  def make_activation_code
    self.activation_code = generate_token
  end
  
  def should_validate_password?
    updating_password || new_record?
  end
  
  def generate_token
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end
