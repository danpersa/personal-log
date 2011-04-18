require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_privacies
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
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    User.create!(:name => name,
    :email => email,
    :password => password,
    :password_confirmation => password)
  end
  
end

def make_ideas
  User.all(:limit => 6).each do |user|
    50.times do
      content = Faker::Lorem.sentence(5).downcase.chomp(".")
      reminder_date = Time.now.utc.tomorrow
      user.ideas.create!(:content => content, 
          :reminder_date => reminder_date, 
          :privacy => Privacy.find_by_name("public"))
    end
  end
end

def make_relationships
  users = User.all(:limit => 70)
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
