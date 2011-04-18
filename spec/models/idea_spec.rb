require 'spec_helper'

describe Idea do

  before(:each) do
    @user = Factory(:user)
    @privacy = Factory(:privacy)
    @attr = { :content => "value for content",
      :privacy => @privacy,
      :reminder_date => Time.now.utc.tomorrow 
    }
  end

  it "should create a new instance given valid attributes" do
    @user.ideas.create!(@attr)
  end
  
  it "should have a reminder date attribute" do
    Idea.new(@attr).should respond_to(:reminder_date)
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
  
  describe "privacy associations" do

    before(:each) do
      @idea = @privacy.ideas.create(@attr)
    end

    it "should have a privacy attribute" do
      @idea.should respond_to(:privacy)
    end

    it "should have the right associated privacy" do
      @privacy.should_not be_nil
      @idea.privacy.should_not be_nil
      # == @privacy
    end
  end
  
  describe "reminder associations" do
    before(:each) do
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
    
    it "should require a reminder date" do
      @user.ideas.build(@attr.merge(:reminder_date => nil)).should_not be_valid
    end
    
    it "should require reminder date that is not in the past" do
      @user.ideas.build(@attr.merge(:reminder_date => 2.days.ago)).should_not be_valid
    end
    
    it "should require a future reminder date" do
      @user.ideas.build(@attr).should be_valid
    end
    
    it "should require a privacy" do
      @user.ideas.build(@attr.merge(:privacy => nil)).should_not be_valid
    end
  end

  describe "from_users_followed_by" do
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))
      @user_post = @user.ideas.create!(@attr.merge(:content => "foo"))
      @user_private_post = @user.ideas.create!(@attr.merge(:content => "foo", 
                                                                :privacy => @private_privacy))
      @other_post = @other_user.ideas.create!(@attr.merge(:content => "bar"))
      @third_post = @third_user.ideas.create!(@attr.merge(:content => "baz"))
      @private_post_of_followd_user = 
          @other_user.ideas.create!(@attr.merge(:content => "bac", 
                                                     :privacy => @private_privacy))
      @user.follow!(@other_user)
    end
    
    it "should have a from_users_followed_by class method" do
      Idea.should respond_to(:from_users_followed_by)
    end
    
    it "should include the followed user's ideas" do
      Idea.from_users_followed_by(@user).should include(@other_post)
    end
    
    it "should include the user's own ideas" do
      Idea.from_users_followed_by(@user).should include(@user_post)
    end
    
    it "should not include an unfollowed user's ideas" do
      Idea.from_users_followed_by(@user).should_not include(@third_post)
    end
    
    it "should not include the followed user's ideas that are private" do
      Idea.from_users_followed_by(@user).should_not include(@private_post_of_followd_user)
    end
    
    it "should include the user's own private ideas" do
      Idea.from_users_followed_by(@user).should include(@user_private_post)
    end
  end
  
  describe "from_user_with_privacy" do
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @other_user = Factory(:user, :email => Factory.next(:email))
      
      @user_post = @user.ideas.create!(@attr.merge(:content => "foo"))
      @user_private_post = @user.ideas.create!(@attr.merge(:content => "foo", 
                                                                :privacy => @private_privacy))
    end
    
    it "should have a from_user_with_privacy class method" do
      Idea.should respond_to(:from_user_with_privacy)
    end
    
    it "should include own public posts" do
      Idea.from_user_with_privacy(@user, @user).should include(@user_post)
    end
    
    it "should include own private posts" do
      Idea.from_user_with_privacy(@user, @user).should include(@user_private_post)
    end
    
    it "should include other user's public posts" do
      Idea.from_user_with_privacy(@user, @other_user).should include(@user_post)
    end
    
    it "should not include other user's private posts" do
      Idea.from_user_with_privacy(@user, @other_user).should_not include(@user_private_post)
    end
    
    it "should include other user's public posts for guest" do
      Idea.from_user_with_privacy(@user, nil).should include(@user_post)
    end
    
    it "should not include other user's private posts for guest" do
      Idea.from_user_with_privacy(@user, nil).should_not include(@user_private_post)
    end
  end
end
