Then /^I should see "([^"]*)"'s ideas content$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content)
  end
end

Then /^I should see "([^"]*)"'s ideas content trimmed$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content.truncate(15))
  end
end


Given /^"([^"]*)" shares some ideas on "([^"]*)"$/ do |email, date|
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
             :reminder_date => Time.parse(date),
             :idea_id => idea.id }
    #has a public reminder
    user.reminders.create!(attr)
  end
end

Given /^"([^"]*)" shares one idea on "([^"]*)"$/ do |email, date|
  user = User.find_by_email(email)
  ideas = []
  ideas << Factory(:idea, :user => user)
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