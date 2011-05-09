require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
   # Define @base_title here.
    @base_title = "Remind me to live"
  end

  describe "GET 'home'" do
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :home
        @title = @base_title + " | Home"
      end
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
      
      it "should paginate" do
        21.times do
          idea = Factory(:idea, :user => @user, :content => "Baz quux")
          Factory(:reminder, :user => @user, :idea => idea, :created_at => 2.day.ago, :privacy => @public_privacy)
        end
        get :home
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => ".?page=2",
                                           :content => "Next")
      end
    end
  end

  describe "GET 'contact'" do
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :contact
        @title =  @base_title + " | Contact"
      end
    end
  end

  describe "GET 'about'" do
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :about
        @title =  @base_title + " | About"
      end
    end
  end

  describe "GET 'reset_password_mail_sent'" do

    it_should_behave_like "successful get request" do
      let(:action) do
        get :reset_password_mail_sent
        @title =  @base_title + " | Reset Password Mail Sent"
      end
    end

    it "should have the correct text" do
      get :reset_password_mail_sent
      response.should have_selector("h1", :content => "The reset password mail was sent!")
    end
  end
end
