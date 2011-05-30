require 'spec_helper'

describe IdeaList do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "The Bucket List"
    }
  end
  
  it "should create a new instance given valid attributes" do
    @user.idea_lists.create!(@attr)
  end
  
  describe "validations" do

    it "should require a user id" do
      IdeaList.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.idea_lists.build(@attr.merge(:content => "  ")).should_not be_valid
    end

    it "should reject long content" do
      @user.idea_lists.build(@attr.merge(:content => "a" * 50)).should_not be_valid
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
      pending
    end
    
    it "should not return the ideas created by another user" do
      ideas = Idea.owned_by(@user)
      ideas.should_not include(@other_user_idea1)
      ideas.should_not include(@other_user_idea2)
      pending
    end
  end
  
end
