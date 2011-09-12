require 'spec_helper'

describe Idea do

  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content" }
  end

  it "should create a new instance given valid attributes" do
    @user.ideas.create!(@attr)
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

  describe "good ideas associations" do

    before(:each) do
      @idea = @user.ideas.create(@attr)
      @good_idea = @idea.good_ideas.create({:user => @user})
    end

    it "should have a good ideas attribute" do
      @idea.should respond_to(:good_ideas)
    end

    it "should have the right associated good_idea" do
      GoodIdea.first.idea_id.should == @idea.id
      GoodIdea.first.idea.should == @idea
    end
    
    it "should destroy associated good ideas" do
      @idea.destroy
      GoodIdea.find_by_id(@good_idea.id).should be_nil
    end
  end
  
  describe "done ideas associations" do

    before(:each) do
      @idea = @user.ideas.create(@attr)
      @done_idea = @idea.done_ideas.create({:user => @user})
    end

    it "should have a done ideas attribute" do
      @idea.should respond_to(:done_ideas)
    end

    it "should have the right associated done idea" do
      DoneIdea.first.idea_id.should == @idea.id
      DoneIdea.first.idea.should == @idea
    end
    
    it "should destroy associated done ideas" do
      @idea.destroy
      DoneIdea.find_by_id(@done_idea.id).should be_nil
    end
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
  
  describe "idea lists associations" do

    before(:each) do
      @idea_list1 = Factory(:idea_list, :user => @user)
      @idea_list2 = Factory(:idea_list, :user => @user, :name => "name 2")
      @idea = @user.ideas.create(@attr)
      idea_list_ownership1 = Factory(:idea_list_ownership, :idea_list => @idea_list1, :idea => @idea)
      idea_list_ownership2 = Factory(:idea_list_ownership, :idea_list => @idea_list2, :idea => @idea)
    end

    it "should have an idea_lists attribute" do
      @idea.should respond_to(:idea_lists)
    end

    it "should have the right idea list" do
      @idea.idea_lists.should == [@idea_list1, @idea_list2]
    end

    it "should not destroy associated idea lists" do
      @idea.destroy
      [@idea_list1, @idea_list2].each do |idea_list|
        IdeaList.find_by_id(idea_list.id).should_not be_nil
      end
    end
  end
  
  describe "idea list ownership associations" do

    before(:each) do
      idea_list1 = Factory(:idea_list, :user => @user)
      idea_list2 = Factory(:idea_list, :user => @user, :name => "name 3")
      @idea = @user.ideas.create(@attr)
      @idea_list_ownership1 = Factory(:idea_list_ownership, :idea_list => idea_list1, :idea => @idea)
      @idea_list_ownership2 = Factory(:idea_list_ownership, :idea_list => idea_list2, :idea => @idea)
    end

    it "should have an idea_list_ownerships attribute" do
      @idea.should respond_to(:idea_list_ownerships)
    end

    it "should have the right idea list ownerships" do
      @idea.idea_list_ownerships.should == [@idea_list_ownership1, @idea_list_ownership2]
    end

    it "should destroy associated idea list ownerships" do
      @idea.destroy
      [@idea_list_ownership1, @idea_list_ownership2].each do |idea_list_ownership|
        IdeaListOwnership.find_by_id(idea_list_ownership.id).should be_nil
      end
    end
  end
  
  describe "users_considering_idea_good association" do
    before(:each) do
      @idea = @user.ideas.create(@attr)
      @other_user = Factory(:user, :email => Factory.next(:email))
      Factory(:good_idea, :user => @user, :idea => @idea)
      Factory(:good_idea, :user => @other_user, :idea => @idea)
    end
    
    it "should have a users_considering_idea_good attribute" do
      @idea.should respond_to(:users_considering_idea_good)
    end
    
    it "should have two associated users" do
      @idea.users_considering_idea_good.all.size.should == 2
    end
  end
  
  describe "users_who_marked_idea_as_done association" do
    before(:each) do
      @idea = @user.ideas.create(@attr)
      @other_user = Factory(:user, :email => Factory.next(:email))
      Factory(:done_idea, :user => @user, :idea => @idea)
      Factory(:done_idea, :user => @other_user, :idea => @idea)
    end
    
    it "should have a users_who_marked_idea_as_done attribute" do
      @idea.should respond_to(:users_who_marked_idea_as_done)
    end
    
    it "should have two associated users" do
      @idea.users_who_marked_idea_as_done.all.size.should == 2
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
  
  describe "shared with other users" do
    
    before(:each) do
      @public_privacy = Factory(:privacy)
      @user_idea = @user.ideas.create!(@attr)
      reminder = Factory(:reminder, :user => @user, :idea => @user_idea, :created_at => 1.day.ago, :privacy => @public_privacy)
    end
    
    it "should return true if other users have reminders for the idea" do
      other_user = Factory(:user, :email => Factory.next(:email))
      other_user_reminder = Factory(:reminder, :user => other_user, :idea => @user_idea, :created_at => 1.day.ago, :privacy => @public_privacy)
      @user_idea.shared_with_other_users?.should == true
    end
    
    it "should return true if other users have private reminders for the idea" do
      private_privacy = Factory(:privacy, :name => "private")
      other_user = Factory(:user, :email => Factory.next(:email))
      other_user_reminder = Factory(:reminder, :user => other_user, :idea => @user_idea, :created_at => 1.day.ago, :privacy => private_privacy)
      @user_idea.shared_with_other_users?.should == true
    end
    
    it "should return false if only the the current user have reminders for the idea" do
      @user_idea.shared_with_other_users?.should == false
    end
    
  end
  
  describe "donate to community" do

    it "should change the current user to the community user" do
      create_community_user
      idea = @user.ideas.create!(@attr)
      idea.user_id.should == @user.id
      idea.donate_to_community!
      idea.reload
      idea.user.name.should == "community"
    end
  end
end
