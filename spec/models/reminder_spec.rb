require 'spec_helper'

describe Reminder do

  before(:each) do
    @micropost = Factory(:micropost)
    @attr = {
      :reminder_date => Time.new,
      :micropost_id => @micropost.id
    }
  end

  it "should create a new instance given valid attributes" do
    Reminder.create!(@attr)
  end

  describe "associations" do

    before(:each) do
      @reminder = Reminder.create!(@attr)
    end

    it "should have a micropost attribute" do
      @reminder.should respond_to(:micropost)
    end
    
    it "should have the right associated micropost" do
      @reminder.micropost.should == @micropost
    end
  end

  describe "validations" do

    it "should require a date" do
      no_date_reminder = Reminder.new(@attr.merge(:reminder_date => nil))
      no_date_reminder.should_not be_valid
    end

    it "should require a micropost id" do
      no_micropost_reminder = Reminder.new(@attr.merge(:micropost_id => nil))
      no_micropost_reminder.should_not be_valid
    end
  end

end
