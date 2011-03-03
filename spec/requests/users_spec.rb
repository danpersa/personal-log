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
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
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
        click_button
        controller.should be_signed_in
        response.should have_selector("div.flash.success", :content => "Welcome")
        user = User.find_by_email @attr[:email]
        user.should_not be_activated
      end
      
    end
  end

  describe "sign in/out" do

    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in :email,    :with => ""
        fill_in :password, :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
      
      it "should not sign a user that is not activated in" do
        user = Factory(:user)
        visit signin_path
        fill_in :email,    :with => user.email
        fill_in :password, :with => user.password
        click_button
        response.should have_selector("div.flash.notice", :content => "activate")
        controller.should_not be_signed_in
      end
      
    end

    describe "success" do
      it "should sign a user in and out" do
        user = Factory(:activated_user)
        visit signin_path
        fill_in :email,    :with => user.email
        fill_in :password, :with => user.password
        click_button
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end
  end
end
