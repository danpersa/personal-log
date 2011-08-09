# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
Privacy.create!(:name => "public")
Privacy.create!(:name => "private")

# the Community User receives all the ideas abandoned by users when they delete their accounts 
community_user = User.create!(:name => "community", :email => "community@remindmetolive.com", :password => "thesercretpassword123")
# we don't let anyone to sign in as the community user
community_user.block!