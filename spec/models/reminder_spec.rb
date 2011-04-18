require 'spec_helper'

describe Reminder do
  before(:each) do
    @idea = Factory(:idea)
    @user = @idea.user
    @privacy = @idea.privacy
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
  
  
end
