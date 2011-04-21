# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Michael Hartl"
  user.email                 "mhartl@example.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :activated_user, :class => User  do |user|
  user.name                  "Michael Jordan"
  user.email                 "jordan.activated@example.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
  user.state                 "active"
  user.activated_at          Time.now.utc
  user.activation_code       "1234567890"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :idea do |idea|
  idea.content "Foo bar"
  idea.association :user
end

Factory.define :privacy do |privacy|
  privacy.name "public"
end

Factory.define :profile do |profile|
  profile.name        "George Bush"
  profile.email       "george.bush@yahoo.com"
  profile.location    "United States of America"
  profile.website     "http://www.bush.com"
  profile.association :user
end

Factory.define :reminder do |reminder|
  reminder.reminder_date Time.now.utc.tomorrow
  reminder.association :idea
  reminder.association :user
  reminder.association :privacy
end
