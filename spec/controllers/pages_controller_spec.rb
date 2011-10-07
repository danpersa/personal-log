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
        visit root_path
        @title = @base_title + " | Home"
      end
    end

    describe "when signed in" do
      
      before(:each) do
        create_privacies
        @user = test_web_sign_in(Factory(:user))
        @public_privacy = Privacy.find_by_name("public")
        other_user = Factory(:user, :email => Factory.next(:email))
        other_user.follow!(@user)
      end
      
      it "should have the right follower/following counts" do
        visit root_path
        page.should have_link("0 following")
        page.should have_link("1 follower")
      end
      
      it "should paginate" do
        21.times do
          idea = Factory(:idea, :user => @user, :content => "Baz quux")
          Factory(:reminder, :user => @user, :idea => idea, :created_at => 2.day.ago, :privacy => @public_privacy)
        end
        visit root_path
        page.should have_selector("div.pagination")
        page.should have_selector("li.disabled", :text => "Previous")
        page.should have_link("Next")
      end
    end
  end

  describe "GET 'contact'" do
    
    it_should_behave_like "successful get request" do
      let(:action) do
        visit contact_path
        @title =  @base_title + " | Contact"
      end
    end
  end

  describe "GET 'about'" do
    
    it_should_behave_like "successful get request" do
      let(:action) do
        visit about_path
        @title =  @base_title + " | About"
      end
    end
  end

  describe "GET 'reset_password_mail_sent'" do

    it_should_behave_like "successful get request" do
      let(:action) do
        visit reset_password_mail_sent_path
        @title =  @base_title + " | Reset Password Mail Sent"
      end
    end

    it "should have the correct text" do
      visit reset_password_mail_sent_path
      page.should have_selector("h1", :text => "The reset password mail was sent!")
    end
  end
end
