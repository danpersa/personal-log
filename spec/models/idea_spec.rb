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
  
  describe "public?" do
    
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
  
  describe "shared_by?(user)" do
    
    describe "success" do
      it "should be true if user has a public reminder for the idea" do
        @public_privacy = Factory(:privacy)
        @public_idea = @user.ideas.create!(@attr)
        @reminder = Factory(:reminder, :user => @user, :idea => @public_idea, :created_at => 1.day.ago, :privacy => @public_privacy)
        @public_idea.should be_shared_by(@user)
      end
      
      it "should be true if the user has a private reminder for the idea" do
        @private_privacy = Factory(:privacy, :name => "private")
        @private_idea = @user.ideas.create!(@attr)
        @private_reminder = Factory(:reminder, :user => @user, :idea => @private_idea, :created_at => 1.day.ago, :privacy => @private_privacy)
        @private_idea.should be_shared_by(@user)
      end
      
    end
    
    describe "failure" do
      it "should be false if the user doesn't have a reminder for the idea" do
        @public_privacy = Factory(:privacy)
        @public_idea = @user.ideas.create!(@attr)
        @public_idea.should_not be_shared_by(@user)
      end
    end
  end
  
  describe "owned_by_user" do
    
    before(:each) do
      @public_privacy = Factory(:privacy)
      @user_idea1 = @user.ideas.create!(@attr)
      @user_idea2 = @user.ideas.create!(@attr)
      other_user = Factory(:user, :email => Factory.next(:email))
      @other_user_idea1 = other_user.ideas.create!(@attr)
      @other_user_idea2 = other_user.ideas.create!(@attr)
    end
    
    it "should return the ideas created by a specified user" do
      ideas = Idea.owned_by(@user)
      ideas.should include(@user_idea1)
      ideas.should include(@user_idea2)
    end
    
    it "should not return the ideas created by another user" do
      ideas = Idea.owned_by(@user)
      ideas.should_not include(@other_user_idea1)
      ideas.should_not include(@other_user_idea2)
    end
  end
end
