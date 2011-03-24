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
  user.activated_at          Time.now
  user.activation_code       "1234567890"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.reminder_date Time.now.tomorrow
  micropost.association :user
  micropost.association :privacy
end

Factory.define :privacy do |privacy|
  privacy.name "public"
end