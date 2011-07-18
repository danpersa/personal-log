Given /^"([^"]*)"' has some reminders$/ do |email|
  user = User.find_by_email(email)
  @idea = Factory(:idea, :user => user)
  if ((@privacy = Privacy.find_by_name("public")).nil?)
    @privacy = Factory(:privacy)
  end
  @attr = { :privacy => @privacy,
            :reminder_date => Time.now.utc.tomorrow,
            :idea_id => @idea.id }
  user.reminders.create!(@attr)
  user.reminders.create!(@attr)
  user.reminders.create!(@attr)
end

Then /^I should see "([^"]*)"'s name$/ do |email|
  user = User.find_by_email(email)
  page.should have_content(user.display_name)
end
