require 'spec_helper'

describe IdeaList do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :name => "The Bucket List" }
  end
  
  it "should create a new instance given valid attributes" do
    @user.idea_lists.create!(@attr)
  end
  
  describe "validations" do

    it "should require a user id" do
      IdeaList.new(@attr).should_not be_valid
    end

    it "should require nonblank name" do
      @user.idea_lists.build(@attr.merge(:name => "  ")).should_not be_valid
    end

    it "should reject long content" do
      @user.idea_lists.build(@attr.merge(:name => "a" * 21)).should_not be_valid
    end
    
    describe "unique name per user" do
    
      it "should require an unique name per user" do
        @user.idea_lists.create!(@attr)
        @user.idea_lists.build(@attr).should_not be_valid
      end
      
      it "should allow other user to use the same name" do
        @user.idea_lists.create!(@attr)
        other_user = Factory(:user, :email => Factory.next(:email))
        other_user.idea_lists.build(@attr).should be_valid
      end
        
    end
  end
  
  describe "user associations" do

    before(:each) do
      @idea_list = @user.idea_lists.create(@attr)
    end

    it "should have a user attribute" do
      @idea_list.should respond_to(:user)
    end

    it "should have the right associated user" do
      @idea_list.user_id.should == @user.id
      @idea_list.user.should == @user
    end
  end
  
  describe "ideas associations" do

    before(:each) do
      @idea_list = @user.idea_lists.create(@attr)
      @idea1 = Factory(:idea, :user => @idea_list.user)
      @idea2 = Factory(:idea, :user => @idea_list.user)
      idea_list_ownership1 = Factory(:idea_list_ownership, :idea_list => @idea_list, :idea => @idea1)
      idea_list_ownership2 = Factory(:idea_list_ownership, :idea_list => @idea_list, :idea => @idea2)
    end

    it "should have an ideas attribute" do
      @idea_list.should respond_to(:ideas)
    end

    it "should have the right ideas" do
      @idea_list.ideas.should == [@idea1, @idea2]
    end

    it "should not destroy associated ideas" do
      @idea_list.destroy
      [@idea1, @idea2].each do |idea|
        Idea.find_by_id(idea.id).should_not be_nil
      end
    end
  end
  
  describe "idea list ownership associations" do

    before(:each) do
      @idea_list = @user.idea_lists.create(@attr)
      idea1 = Factory(:idea, :user => @idea_list.user)
      idea2 = Factory(:idea, :user => @idea_list.user)
      @idea_list_ownership1 = Factory(:idea_list_ownership, :idea_list => @idea_list, :idea => idea1)
      @idea_list_ownership2 = Factory(:idea_list_ownership, :idea_list => @idea_list, :idea => idea2)
    end

    it "should have an idea_list_ownerships attribute" do
      @idea_list.should respond_to(:idea_list_ownerships)
    end

    it "should have the right idea list ownerships" do
      @idea_list.idea_list_ownerships.should == [@idea_list_ownership1, @idea_list_ownership2]
    end

    it "should destroy associated idea list ownerships" do
      @idea_list.destroy
      [@idea_list_ownership1, @idea_list_ownership2].each do |idea_list_ownership|
        IdeaListOwnership.find_by_id(idea_list_ownership.id).should be_nil
      end
    end
  end
  
  describe "owned_by_user" do
    
    before(:each) do
      @user_idea_list1 = @user.idea_lists.create!(@attr)
      @user_idea_list2 = @user.idea_lists.create!({:name => "name 1"})
      other_user = Factory(:user, :email => Factory.next(:email))
      @other_user_idea_list1 = other_user.idea_lists.create!(@attr)
      @other_user_idea_list2 = other_user.idea_lists.create!({:name => "name 1"})
    end
    
    it "should return the idea lists created by a specified user" do
      idea_lists = IdeaList.owned_by(@user)
      idea_lists.should include(@user_idea_list1)
      idea_lists.should include(@user_idea_list2)
    end
    
    it "should not return the idea lists created by another user" do
      idea_lists = IdeaList.owned_by(@user)
      idea_lists.should_not include(@other_user_idea_list1)
      idea_lists.should_not include(@other_user_idea_list2)
    end
  end
  
end
