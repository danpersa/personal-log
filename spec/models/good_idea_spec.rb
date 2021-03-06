require 'spec_helper'

describe GoodIdea do
  
  before(:each) do
    @idea = Factory(:idea)
    @user = @idea.user
    @attr = {:idea => @idea, :user => @user }
  end
  
  it "should create a new instance given valid attributes" do
    GoodIdea.create!(@attr)
  end
  
  describe "validations" do

    it "should require a user id" do
      GoodIdea.new({:idea => @idea}).should_not be_valid
    end

    it "should require an idea id" do
      GoodIdea.new({:user => @user}).should_not be_valid
    end
  end
  
  describe "user associations" do

    before(:each) do
      @good_idea = GoodIdea.create!(@attr)
    end

    it "should have a user attribute" do
      @good_idea.should respond_to(:user)
    end

    it "should have the right associated user" do
      @good_idea.user_id.should == @user.id
      @good_idea.user.should == @user
    end
  end
  
  describe "idea associations" do

    before(:each) do
      @good_idea = @idea.good_ideas.create!(@attr)
    end

    it "should have an idea attribute" do
      @good_idea.should respond_to(:idea)
    end

    it "should have the right associated idea" do
      @good_idea.idea_id.should == @idea.id
      @good_idea.idea.should == @idea
    end
  end
  
end
