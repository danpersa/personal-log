require 'spec_helper'

describe DoneIdea do
  
  before(:each) do
    @idea = Factory(:idea)
    @user = @idea.user
    @attr = {:idea => @idea, :user => @user }
  end
  
  it "should create a new instance given valid attributes" do
    DoneIdea.create!(@attr)
  end
  
  describe "validations" do

    it "should require a user id" do
      DoneIdea.new({:idea => @idea}).should_not be_valid
    end

    it "should require an idea id" do
      DoneIdea.new({:user => @user}).should_not be_valid
    end
  end
  
  describe "user association" do

    before(:each) do
      @done_idea = GoodIdea.create!(@attr)
    end

    it "should have a user attribute" do
      @done_idea.should respond_to(:user)
    end

    it "should have the right associated user" do
      @done_idea.user_id.should == @user.id
      @done_idea.user.should == @user
    end
  end
  
  describe "idea association" do

    before(:each) do
      @done_idea = @idea.done_ideas.create!(@attr)
    end

    it "should have an idea attribute" do
      @done_idea.should respond_to(:idea)
    end

    it "should have the right associated idea" do
      @done_idea.idea_id.should == @idea.id
      @done_idea.idea.should == @idea
    end
  end
end
