require 'spec_helper'

describe GoodIdea do
  
  before(:each) do
    @idea = Factory(:idea)
    @user = @idea.user
    @attr = { :user => @user }
  end
  
  it "should create a new instance given valid attributes" do
    @idea.good_ideas.create!(@attr)
  end
  
  describe "validations" do

    it "should require a user id" do
      IdeaList.new(@attr).should_not be_valid
    end

    it "should require nonblank name" do
      @user.idea_lists.build(@attr.merge(:name => "  ")).should_not be_valid
    end

    it "should reject long content" do
      @user.idea_lists.build(@attr.merge(:name => "a" * 31)).should_not be_valid
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
  
end
