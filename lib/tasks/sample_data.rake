require 'faker'

namespace :db do
  desc "Fill database with sample data "
  task :populate => :environment do
    puts ::Rails.env
    Rake::Task['db:reset'].invoke
    #make_privacies
    make_users
    make_ideas
    make_relationships
  end
end

def make_users
  admin = User.create!(:name => "Example User",
  :email => "example@railstutorial.org",
  :password => "foobar",
  :password_confirmation => "foobar")
  admin.toggle!(:admin)
  admin.activate!
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    user = User.create!(:name => name,
    :email => email,
    :password => password,
    :password_confirmation => password)
    user.activate!
  end
end

def make_ideas
  first_user = User.first
  first_idea = first_user.ideas.create!(:content => "to go to school")
  public_privacy = Privacy.find_by_name("public")
  reminder_date = Time.now.utc.tomorrow
  User.all(:limit => 6).each do |user|
    50.times do
      content = Faker::Lorem.sentence(5).downcase.chomp(".")
      idea = user.ideas.create!(:content => content)
      user.reminders.create!(:reminder_date => reminder_date, 
          :privacy => public_privacy, :idea => idea)
    end
    user.reminders.create!(:reminder_date => reminder_date, 
          :privacy => public_privacy, :idea => first_idea)
  end
end

def make_relationships
  users = User.all(:limit => 7)
  user = users.first
  following = users[1..50]
  followers = users[3..40]
  following.each { |followed| user.follow!(followed) }
  followers.each { |follower| follower.follow!(user) }
end

def make_privacies
  Privacy.create!(:name => "public")
  Privacy.create!(:name => "private")
end
