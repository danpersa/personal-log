# == Schema Information
# Schema version: 20110405072140
#
# Table name: privacies
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Privacy < ActiveRecord::Base
  attr_accessible :name

  validates :name,  :presence   => true,
            :uniqueness => { :case_sensitive => false }
  validates_inclusion_of :name, :in => %w(private public),
    :message => "%{value} is not a valid privacy"
    
  has_many :ideas
  has_many :reminders

end
