require 'spec_helper'

describe "LayoutLinks" do
  it "should have a Home page at '/'" do
    visit '/'
    page.should have_selector('title', :text => "Home")
  end

  it "should have a Contact page at '/contact'" do
    visit '/contact'
    page.should have_selector('title', :text => "Contact")
  end

  it "should have an About page at '/about'" do
    visit '/about'
    page.should have_selector('title', :text => "About")
  end

  it "should have a Help page at '/help'" do
    visit '/help'
    page.should have_selector('title', :text => "Help")
  end

  it "should have a Sign Up page at '/signup'" do
    visit '/signup'
    page.should have_selector('title', :text => "Sign up")
  end

  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      page.should have_link("Sign in")
    end
  end

  describe "when signed in" do

    before(:each) do
      create_privacies
      @user = Factory(:activated_user)
      visit signin_path
      fill_in "Email",    :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
    end

    it "should have a signout link" do
      visit root_path
      page.should have_link("Sign out")
    end

    it "should have a profile link" do
      visit root_path
      page.should have_link("Profile")
    end
  end
end

