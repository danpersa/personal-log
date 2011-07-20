Given /^"([^"]*)"' has some reminders$/ do |email|
  user = User.find_by_email(email)
  idea = Factory(:idea, :user => user)
  if ((privacy = Privacy.find_by_name("public")).nil?)
    privacy = Factory(:privacy)
  end
  attr = { :privacy => privacy,
            :reminder_date => Time.now.utc.tomorrow,
            :idea_id => idea.id }
  #has a public reminder
  user.reminders.create!(attr)
  user.reminders.create!(attr)
  user.reminders.create!(attr)
end

Given /^"([^"]*)" follows "([^"]*)"$/ do |email, followed_email|
  user = User.find_by_email(email)
  followed_user = User.find_by_email(followed_email)
  user.follow!(followed_user)
end

Given /^"([^"]*)" shares an idea$/ do |email|
  user = User.find_by_email(email)
  idea = Factory(:idea, :user => user)
  if ((privacy = Privacy.find_by_name("public")).nil?)
    privacy = Factory(:privacy)
  end
  attr = { :privacy => privacy,
           :reminder_date => Time.now.utc.tomorrow,
           :idea_id => idea.id }
  #has a public reminder
  user.reminders.create!(attr)
end

Given /^"([^"]*)" shares some ideas$/ do |email|
  user = User.find_by_email(email)
  ideas = []
  5.times do
    ideas << Factory(:idea, :user => user)
  end
  if ((privacy = Privacy.find_by_name("public")).nil?)
    privacy = Factory(:privacy)
  end
  
  ideas.each do |idea|
    attr = { :privacy => privacy,
             :reminder_date => Time.now.utc.tomorrow,
             :idea_id => idea.id }
    #has a public reminder
    user.reminders.create!(attr)
  end
end

Given /^"([^"]*)" shares the same idea$/ do |email|
  user = User.find_by_email(email)
  idea = Idea.first
  if ((privacy = Privacy.find_by_name("public")).nil?)
    privacy = Factory(:privacy)
  end
  attr = { :privacy => privacy,
            :reminder_date => Time.now.utc.tomorrow,
            :idea_id => idea.id }
  #has a public reminder
  user.reminders.create!(attr)
end

Then /^I should see "([^"]*)"'s display name$/ do |email|
  user = User.find_by_email(email)
  page.should have_content(user.display_name)
end

Then /^"([^"]*)" should follow "([^"]*)"$/ do |email, followed_email|
  user = User.find_by_email(email)
  followed_user = User.find_by_email(followed_email)
  user.following(followed_user).should_not be_nil
end