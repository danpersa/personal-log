Given /^I sign in with "([^"]*)" and "([^"]*)"$/ do |email, password|
  visit signin_path
  fill_in "Email",    :with => email
  fill_in "Password", :with => password
  click_button "Sign in"
end
