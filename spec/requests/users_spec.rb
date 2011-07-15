require 'spec_helper'

describe "Users Request" do

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => ""
          fill_in "Email",        :with => ""
          fill_in "Password",     :with => ""
          fill_in "Confirmation", :with => ""
          click_button "Sign up"
          page.should have_css("div#error_explanation")
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end
      
      it "should create an user that is not activated" do
        visit signup_path
        fill_in "Name",         :with => @attr[:name]
        fill_in "Email",        :with => @attr[:email]
        fill_in "Password",     :with => @attr[:password]
        fill_in "Confirmation", :with => @attr[:password_confirmation]
        click_button "Sign up"
        page.should_not have_link "Sign out"
        page.should have_css("div.flash.success", :text => "email")
        user = User.find_by_email @attr[:email]
        user.should_not be_activated
      end
      
    end
  end

  describe "sign in/out" do

    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in "Email",    :with => ""
        fill_in "Password", :with => ""
        click_button "Sign in"
        page.should have_css("div.flash.error", :text => "Invalid")
      end
      
      it "should not sign in a user that is not activated" do
        user = Factory(:user)
        visit signin_path
        fill_in "Email",    :with => user.email
        fill_in "Password", :with => user.password
        click_button "Sign in"
        page.should have_css("div.flash.notice", :text => "activate")
        page.should_not have_link "Sign out"
      end
      
    end

    describe "success" do
      it "should sign a user in and out" do
        user = Factory.create(:activated_user)
        create_privacies
        visit signin_path
        fill_in "Email",    :with => user.email
        fill_in "Password", :with => user.password
        click_button "Sign in"
        page.should have_link "Sign out"
        click_link "Sign out"
        page.should_not have_link "Sign out"
      end
    end
  end
  
  describe "activation process" do
    
    before(:each) do
      @attr = { :name => "New User", :email => "user@example.com",
                :password => "foobar", :password_confirmation => "foobar" }
    end
    
    it "success" do
      create_privacies
      visit signup_path
      fill_in "Name",         :with => @attr[:name]
      fill_in "Email",        :with => @attr[:email]
      fill_in "Password",     :with => @attr[:password]
      fill_in "Confirmation", :with => @attr[:password_confirmation]
      click_button "Sign up"
      page.should_not have_link "Sign out"
      
      user = User.find_by_email @attr[:email]
      user.should_not be_activated
      
      # we try to sign in without activation
      visit signin_path
      fill_in "Email",    :with => @attr[:email]
      fill_in "Password", :with => @attr[:password]
      click_button "Sign in"
      page.should_not have_link "Sign out"
      # we activate the user
      visit activate_path(:activation_code => user.activation_code)
      page.should have_link "Sign out"
      user = User.find_by_email @attr[:email]
      user.should be_activated
      
      click_link "Sign out"
      page.should_not have_link "Sign out"
      
      # we try to sign in after activation
      visit signin_path
      fill_in "Email",    :with => @attr[:email]
      fill_in "Password", :with => @attr[:password]
      # save_and_open_page
      click_button "Sign in"
      page.should have_link "Sign out"
      
      click_link "Sign out"
      page.should_not have_link "Sign out"
      
      # we try to sign in with blank password
      visit signin_path
      fill_in "Email",    :with => @attr[:email]
      fill_in "Password", :with => ""
      click_button "Sign in"
      page.should_not have_link "Sign out"
    end
  end
end
