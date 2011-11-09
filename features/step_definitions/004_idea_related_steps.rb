Given /^"([^"]*)" shares (\d+) ideas? on "([^"]*)"$/ do |email, number_of_ideas, date|
  user = User.find_by_email(email)
  ideas = []
  number_of_ideas.to_i.times do
    ideas << Factory(:idea, :user => user)
  end
  if ((privacy = Privacy.find_by_name("public")).nil?)
    privacy = Factory(:privacy)
  end
  
  ideas.each do |idea|
    attr = { :privacy => privacy,
             :reminder_date => Time.parse(date),
             :idea_id => idea.id }
    #has a public reminder
    user.reminders.create!(attr)
  end
end

Given /^"([^"]*)" shares (\d+) ideas?$/ do |email, number_of_ideas|
  user = User.find_by_email(email)
  ideas = []
  number_of_ideas.to_i.times do
    ideas << Factory(:idea, :user => user)
  end
  if ((privacy = Privacy.find_by_name("public")).nil?)
    privacy = Factory(:privacy)
  end
  
  ideas.each do |idea|
    attr = { :privacy => privacy,
             :reminder_date => Time.now.next_year,
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
           :reminder_date => Time.now.next_year,
           :idea_id => idea.id }
  #has a public reminder
  user.reminders.create!(attr)
end

Then /^I should see "([^"]*)"'s ideas content$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content)
  end
end

Then /^I should see "([^"]*)"'s ideas content trimmed$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content.truncate(22))
  end
end
