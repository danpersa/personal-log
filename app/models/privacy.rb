class Privacy < ActiveRecord::Base
  attr_accessible :name

  validates :name,  :presence   => true,
            :uniqueness => { :case_sensitive => false }
  validates_inclusion_of :name, :in => %w(private public),
    :message => "%{value} is not a valid privacy"
    
  has_many :microposts

end
