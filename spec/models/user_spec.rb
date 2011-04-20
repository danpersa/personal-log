require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject emails that are to long" do
    long_email = "a" * 256 + "@yahoo.com"
    long_email_user = User.new(@attr.merge(:email => long_email))
    long_email_user.should_not be_valid
  end

  it "should reject duplicate email addresses" do
  # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should not permit states that are not defined" do
    user_with_invalid_state = User.create!(@attr)
    user_with_invalid_state.state = "invalid_state"
    user_with_invalid_state.should_not be_valid
  end
  
  it_should_behave_like "password validation" do
    let(:action) do
      @valid_object = User.new(@attr)
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "idea associations" do

    before(:each) do
      @privacy = Factory(:privacy)
      @user = User.create(@attr)
      @mp1 = Factory(:idea, :user => @user, :created_at => 1.day.ago, :privacy => @privacy)
      @mp2 = Factory(:idea, :user => @user, :created_at => 1.hour.ago, :privacy => @privacy)
    end

    it "should have a ideas attribute" do
      @user.should respond_to(:ideas)
    end

    it "should have the right ideas in the right order" do
      @user.ideas.should == [@mp2, @mp1]
    end

    it "should destroy associated ideas" do
      @user.destroy
      [@mp1, @mp2].each do |idea|
        Idea.find_by_id(idea.id).should be_nil
      end
    #lambda do
    #   Idea.find(idea.id)
    #end.should raise_error(ActiveRecord::RecordNotFound)
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's ideas" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end
      
      it "should not include a different user's ideas" do
        mp3 = Factory(:idea, 
            :user => Factory(:user, :email => Factory.next(:email)),
            :privacy => @privacy)
        @user.feed.should_not include(mp3)
      end
      
      it "should include the ideas of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:idea, :user => followed, :privacy => @privacy)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end
    end
  end
  
  describe "reminder associations" do
    before(:each) do
      @privacy = Factory(:privacy)
      @user = User.create(@attr)
      @idea = Factory(:idea, :user => @user, :created_at => 1.day.ago, :privacy => @privacy)
      @reminder1 = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @privacy, :created_at => 1.day.ago)
      @reminder2 = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @privacy, :created_at => 1.hour.ago)
    end
    
    it "should have a reminders attribute" do
      @user.should respond_to(:reminders)
    end
    
    it "should have the right ideas in the right order" do
      @user.reminders.should == [@reminder2, @reminder1]
    end
    
    it "should destroy associated reminders" do
      @user.destroy
      Reminder.find_by_id(@reminder1.id).should be_nil
      Reminder.find_by_id(@reminder2.id).should be_nil
    end
  end

  describe "relationships" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
  
  describe "states" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an activation code" do
      @user.activation_code.should_not be_empty      
    end
    
    it "should not be activated" do
      @user.activated?.should == false
    end

    it "should be created in the pending state" do
      @user.state.should == "pending"
    end

    it "should switch to active state and be activated" do
      @user.activate!
      @user.state.should == "active"
      @user.activated?.should == true
    end
    
    it "should not change password" do
      @user.activate!
      @user.password.should_not be_blank
    end
  end
  
  describe "reset password" do
    
    before(:each) do
      @user = Factory(:activated_user)
    end
    
    it "should have a reset password method" do
      @user.should respond_to(:reset_password)
    end
    
    it "should generate a password reset code" do
      @user.reset_password
      @user.password_reset_code.should_not be_nil
    end
    
    it "should change the previous password reset code" do
      @user.reset_password
      last_reset_password = @user.password_reset_code
      @user.reset_password
      last_reset_password.should_not == @user.password_reset_code
    end
    
    it "should change the previous reset password mail sent at" do
      @user.reset_password
      last_reset_password_mail_sent_at = @user.reset_password_mail_sent_at
      @user.reset_password
      last_reset_password_mail_sent_at.should_not == @user.reset_password_mail_sent_at
    end
  end
  
  describe "reset_password_expired?" do
    
    before(:each) do
      @user = Factory(:activated_user)
    end
    
    it "should be expired if the reset password mail was sent two days ago" do
      @user.reset_password_mail_sent_at = 2.days.ago
      @user.reset_password_expired?.should == true
    end
    
    it "should not be expired if the reset password mail was sent two hours ago" do
      @user.reset_password_mail_sent_at = 2.hours.ago
      @user.reset_password_expired?.should == false
    end
  end
  
  describe "profile association" do
    
    it "should have a profile attribute" do
      user = Factory(:activated_user)
      user.should respond_to(:profile)
    end
  end
  
  describe "display name" do
    before(:each) do
      @profile = Factory(:profile)
      @user = @profile.user
    end
    
    it "should return the profile name" do
      @user.display_name.should == @profile.name
    end
    
    it "should return the user name if no user profile name" do
      @user.profile.name = ""
      @user.display_name.should == @user.name
    end
    
    it "should return the user name if no profile" do
      user = Factory(:activated_user)
      user.display_name.should == user.name
    end
  end
end
