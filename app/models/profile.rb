require 'validators/email_format_validator'

class Profile < ActiveRecord::Base
  attr_accessible :name, :email, :location, :website
  
  validates :name,      :length       => { :maximum => 50 } 
  validates :email,     :email_format => true,
                        :length       => { :maximum => 255 }
  validates :location,  :length       => { :maximum => 100 }
  validates :website,   :length       => { :maximum => 100 }                  
end
