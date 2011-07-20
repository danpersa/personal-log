Then /^I should see "([^"]*)"'s ideas content$/ do |email|
  user = User.find_by_email(email)
  user.ideas.each do |idea|
    page.should have_content(idea.content)
  end
end
