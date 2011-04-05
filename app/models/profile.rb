# == Schema Information
# Schema version: 20110405072140
#
# Table name: profiles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  email      :string(255)
#  website    :string(255)
#  location   :string(255)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer(4)
#

require 'validators/email_format_validator'

class Profile < ActiveRecord::Base
  attr_accessible :name, :email, :location, :website, :user_id
  
  belongs_to :user
  
  validates :name,      :length       => { :maximum => 50 } 
  validates :email,     :email_format => true,
                        :length       => { :maximum => 255 }
  validates :location,  :length       => { :maximum => 100 }
  validates :website,   :length       => { :maximum => 100 }
  validates :user_id,   :presence     => true
  
  def empty?
    return true if self.name.empty? and self.email.empty? and self.location.empty? and self.website.empty?
    return false  
  end                  
end
