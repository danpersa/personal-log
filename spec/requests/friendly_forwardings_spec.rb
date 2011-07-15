require 'spec_helper'

describe "FriendlyForwardings" do
  it "should forward to the requested page after signin" do
    user = Factory(:activated_user)
    visit edit_user_path(user)
    # The test automatically follows the redirect to the signin page.
    fill_in 'Email',    :with => user.email
    fill_in 'Password', :with => user.password
    click_button "Sign in"
    # The test follows the redirect again, this time to users/edit.
    page.should have_content('Settings')
  end
  
  it "should forward to home page after signin" do
    user = Factory(:activated_user)
    create_privacies
    visit signin_path
    fill_in 'Email',    :with => user.email
    fill_in 'Password', :with => user.password
    click_button "Sign in"
    # The test follows the redirect again, this time to home.
    page.should have_content('Remind me to')
  end
end
