require 'spec_helper'

describe Idea do

  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content"
    }
  end

  it "should create a new instance given valid attributes" do
    @user.ideas.create!(@attr)
  end
  

  describe "user associations" do

    before(:each) do
      @idea = @user.ideas.create(@attr)
    end

    it "should have a user attribute" do
      @idea.should respond_to(:user)
    end

    it "should have the right associated user" do
      @idea.user_id.should == @user.id
      @idea.user.should == @user
    end
  end
  
  describe "reminder associations" do
    before(:each) do
      @privacy = Factory(:privacy)
      @idea = @user.ideas.create!(@attr)
      @reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => @privacy)
    end
    
    it "should have a reminders attribute" do
      @idea.should respond_to(:reminders)
    end
    
    it "should destroy associated reminders" do
      @idea.destroy
      Reminder.find_by_id(@reminder.id).should be_nil
    end
  end

  describe "validations" do

    it "should require a user id" do
      Idea.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.ideas.build(@attr.merge(:content => "  ")).should_not be_valid
    end

    it "should reject long content" do
      @user.ideas.build(@attr.merge(:content => "a" * 141)).should_not be_valid
    end
  end
  
  describe "is_public?" do
    
    it "should be public if it has at least one public reminder" do
      @public_privacy = Factory(:privacy)
      @public_idea = @user.ideas.create!(@attr)
      @reminder = Factory(:reminder, :user => @user, :idea => @public_idea, :created_at => 1.day.ago, :privacy => @public_privacy)
      @public_idea.should be_public
    end
    
    it "should not be public if it has only private reminders" do
      @private_privacy = Factory(:privacy, :name => "private")
      @private_idea = @user.ideas.create!(@attr)
      @private_reminder = Factory(:reminder, :user => @user, :idea => @private_idea, :created_at => 1.day.ago, :privacy => @private_privacy)
      @private_idea.should_not be_public
    end
  end
end
