require 'spec_helper'

describe Reminder do
  before(:each) do
    @idea = Factory(:idea)
    @user = @idea.user
    @privacy = Factory(:privacy)
    @attr = { :privacy => @privacy,
              :reminder_date => Time.now.utc.tomorrow,
              :idea_id => @idea.id
      }
  end
  
  it "should create a new instance given valid attributes" do
    @user.reminders.create!(@attr)
  end
  
  it "should have a reminder date attribute" do
    Reminder.new(@attr).should respond_to(:reminder_date)
  end
  
  describe "idea associations" do

    before(:each) do
      @reminder = @user.reminders.create(@attr)
    end

    it "should have an idea attribute" do
      @reminder.should respond_to(:idea)
    end

    it "should have the right associated idea" do
      @reminder.idea_id.should == @idea.id
      @reminder.idea.should == @idea
    end
  end
  
  describe "user associations" do

    before(:each) do
      @reminder = @user.reminders.create(@attr)
    end

    it "should have a user attribute" do
      @reminder.should respond_to(:user)
    end

    it "should have the right associated user" do
      @reminder.user_id.should == @user.id
      @reminder.user.should == @user
    end
  end
  
  describe "privacy associations" do

    before(:each) do
      @reminder = @privacy.reminders.create(@attr)
    end

    it "should have a privacy attribute" do
      @reminder.should respond_to(:privacy)
    end

    it "should have the right associated privacy" do
      @privacy.should_not be_nil
      @reminder.privacy.should_not be_nil
      @reminder.privacy.should == @privacy
    end
  end
  
  describe "validations" do

    it "should require a user id" do
      Reminder.new(@attr.merge :user_id => nil, :idea_id => @idea.id).should_not be_valid
    end

    it "should require an idea id" do
      Reminder.new(@attr).should_not be_valid
    end
    
    it "should require a reminder date" do
      @user.reminders.build(@attr.merge(:reminder_date => nil)).should_not be_valid
    end
    
    it "should require reminder date that is not in the past" do
      @user.reminders.build(@attr.merge(:reminder_date => 2.days.ago)).should_not be_valid
    end
    
    it "should require a future reminder date" do
      @user.reminders.build(@attr).should be_valid
    end
    
    it "should require a privacy" do
      @user.reminders.build(@attr.merge(:privacy => nil)).should_not be_valid
    end
  end
  
  describe "from_users_followed_by" do
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))
      @reminder = @user.reminders.create!(@attr)
      @private_reminder = @user.reminders.create!(@attr.merge(:privacy => @private_privacy))
      @other_reminder = @other_user.reminders.create!(@attr)
      @third_reminder = @third_user.reminders.create!(@attr)
      @private_reminder_of_followd_user = 
          @other_user.reminders.create!(@attr.merge(:privacy => @private_privacy))
      @user.follow!(@other_user)
    end
    
    it "should have a from_users_followed_by class method" do
      Reminder.should respond_to(:from_users_followed_by)
    end
    
    it "should include the followed user's reminders" do
      Reminder.from_users_followed_by(@user).should include(@other_reminder)
    end
    
    it "should include the user's own reminders" do
      Reminder.from_users_followed_by(@user).should include(@reminder)
    end
    
    it "should not include an unfollowed user's ideas" do
      Reminder.from_users_followed_by(@user).should_not include(@third_reminder)
    end
    
    it "should not include the followed user's reminders that are private" do
      Reminder.from_users_followed_by(@user).should_not include(@private_reminder_of_followd_user)
    end
    
    it "should include the user's own private reminders" do
      Reminder.from_users_followed_by(@user).should include(@private_reminder)
    end
  end
  
  describe "from_user_with_privacy" do
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @other_user = Factory(:user, :email => Factory.next(:email))
      
      @reminder = @user.reminders.create!(@attr)
      @private_reminder = @user.reminders.create!(@attr.merge(:privacy => @private_privacy))
    end
    
    it "should have a from_user_with_privacy class method" do
      Reminder.should respond_to(:from_user_with_privacy)
    end
    
    it "should include own public reminders" do
      Reminder.from_user_with_privacy(@user, @user).should include(@reminder)
    end
    
    it "should include own private reminders" do
      Reminder.from_user_with_privacy(@user, @user).should include(@private_reminder)
    end
    
    it "should include other user's public reminders" do
      Reminder.from_user_with_privacy(@user, @other_user).should include(@reminder)
    end
    
    it "should not include other user's private reminders" do
      Reminder.from_user_with_privacy(@user, @other_user).should_not include(@private_reminder)
    end
    
    it "should include other user's public reminders for guest" do
      Reminder.from_user_with_privacy(@user, nil).should include(@reminder)
    end
    
    it "should not include other user's private reminders for guest" do
      Reminder.from_user_with_privacy(@user, nil).should_not include(@private_reminder)
    end
  end
  
  describe "from_idea_by_privacy" do
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @reminder = @user.reminders.create!(@attr)
      @private_reminder = @user.reminders.create!(@attr.merge(:privacy => @private_privacy))
    end
    
    it "should return only the private reminders" do
      reminders = Reminder.from_idea_by_privacy(@idea, @private_privacy)
      reminders.size.should == 1
      reminders.first.privacy.should == @private_privacy
    end
    
    it "should return only the public reminders" do
      reminders = Reminder.from_idea_by_privacy(@idea, @privacy)
      reminders.size.should == 1
      reminders.first.privacy.should == @privacy
    end
  end
  
  describe "public_reminders_for_idea" do
    
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @reminder = @user.reminders.create!(@attr)
      @private_reminder = @user.reminders.create!(@attr.merge(:privacy => @private_privacy))
    end
    
    it "should return the correct value" do
      Reminder.public_reminders_for_idea(@idea).size == 1
    end
  end
  
  describe "public_or_users_reminders_for_idea" do
    
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @other_user = Factory(:user, :email => Factory.next(:email))
      @user.follow!(@other_user)
      @reminder1 = @other_user.reminders.create!(@attr)
      @reminder = @user.reminders.create!(@attr)
      @private_reminder = @user.reminders.create!(@attr.merge(:privacy => @private_privacy))
    end
    
    it "should return the correct value" do
      Reminder.public_or_users_reminders_for_idea(@idea, @user).size == 3
    end
  end
end
