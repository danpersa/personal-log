require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
  # Define @base_title here.
    @base_title = "Personal Log"
  end

  describe "GET 'home'" do
    
    it "should be successful" do
      get 'home'
      response.should be_success
    end

    it "should have the correct title" do
      get 'home'
      response.should have_selector("title", :content => @base_title + " | Home")
    end

    describe "when signed in" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @public_privacy = Privacy.create(:name => "public")
        other_user = Factory(:user, :email => Factory.next(:email))
        other_user.follow!(@user)
      end
      
      it "should have the right follower/following counts" do
        get :home
        response.should have_selector("a", :href => following_user_path(@user),
          :content => "0 following")
        response.should have_selector("a", :href => followers_user_path(@user),
          :content => "1 follower")
      end
    end
  end

  describe "GET 'contact'" do
    
    it "should be successful" do
      get 'contact'
      response.should be_success
    end
    
    it "should have the correct title" do
      get 'contact'
      response.should have_selector "title", :content => @base_title + " | Contact"
    end
  end

  describe "GET 'about'" do
    
    it "should be successful" do
      get 'about'
      response.should be_success
    end
    
    it "should have the correct title" do
      get 'about'
      response.should have_selector "title", :content => @base_title + " | About"
    end
  end

  describe "GET 'reset_password_mail_sent'" do

    it "should be successful" do
      get :reset_password_mail_sent
      response.should be_successful
    end

    it "should have the correct title" do
      get :reset_password_mail_sent
      response.should have_selector("title", :content => @base_title + " | Reset Password Mail Sent")
    end

    it "should have the correct text" do
      get :reset_password_mail_sent
      response.should have_selector("h1", :content => "The reset password mail was sent!")
    end
  end
end
