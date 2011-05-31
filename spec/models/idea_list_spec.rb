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

    it "should require nonblank content" do
      @user.idea_lists.build(@attr.merge(:name => "  ")).should_not be_valid
    end

    it "should reject long content" do
      @user.idea_lists.build(@attr.merge(:name => "a" * 21)).should_not be_valid
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
  
  describe "owned_by_user" do
    
    before(:each) do
      @user_idea_list1 = @user.idea_lists.create!(@attr)
      @user_idea_list2 = @user.idea_lists.create!(@attr)
      other_user = Factory(:user, :email => Factory.next(:email))
      @other_user_idea_list1 = other_user.idea_lists.create!(@attr)
      @other_user_idea_list2 = other_user.idea_lists.create!(@attr)
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
