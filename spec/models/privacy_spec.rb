require 'spec_helper'

describe Privacy do
  
  before(:each) do
    @attr = {
      :name => "private"
    }
  end
  
  describe "validations" do
    it "should permit only public or private name" do
      Privacy.create(@attr).should be_valid
      Privacy.create(@attr.merge(:name => "public")).should be_valid
      Privacy.create(@attr.merge(:name => "other")).should_not be_valid
    end
    
    it "should reject duplicate names" do
      Privacy.create(@attr)
      privacy_with_duplicate_name = Privacy.new(@attr)
      privacy_with_duplicate_name.should_not be_valid
    end
  end
  
  describe "micropost associations" do
    before(:each) do
      @privacy = Factory(:privacy)
      @micropost = Factory(:micropost, :privacy => @privacy, :created_at => 1.day.ago)
    end
    
    it "should have a microposts attribute" do
      @privacy.should respond_to(:microposts)
    end
  end
end
