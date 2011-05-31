require 'spec_helper'

describe IdeaListOwnership do
  before(:each) do
    @idea = Factory(:idea)
    @idea_list = Factory(:idea_list, :user => @idea.user)
    @attr = { :idea_list_id => @idea_list.id, :idea_id => @idea.id }
  end
  
  it "should create a new instance given valid attributes" do
    IdeaListOwnership.create!(@attr)
  end
  
  describe "validations" do

    it "should require an idea id" do
      IdeaListOwnership.new({:idea_list_id => @idea_list.id}).should_not be_valid
    end
    
    it "should require an idea list id" do
      IdeaListOwnership.new({:idea_id => @idea.id}).should_not be_valid
    end
    
    it "should prevent duplicates" do
      IdeaListOwnership.create!(@attr)
      IdeaListOwnership.new(@attr).should_not be_valid
    end
  end
  
  describe "idea associations" do

    before(:each) do
      @idea_list_ownership = @idea.idea_list_ownerships.create({:idea_list_id => @idea_list.id})
    end

    it "should have an idea attribute" do
      @idea_list_ownership.should respond_to(:idea)
    end

    it "should have the right associated idea" do
      @idea_list_ownership.idea_id.should == @idea.id
      @idea_list_ownership.idea.should == @idea
    end
  end

  describe "idea list associations" do

    before(:each) do
      @idea_list_ownership = @idea_list.idea_list_ownerships.create({:idea_id => @idea.id})
    end

    it "should have an idea list attribute" do
      @idea_list_ownership.should respond_to(:idea_list)
    end

    it "should have the right associated idea" do
      @idea_list_ownership.idea_list_id.should == @idea_list.id
      @idea_list_ownership.idea_list.should == @idea_list
    end
  end
  
end
