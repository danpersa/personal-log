require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = Factory(:user)
    @privacy = Privacy.create(:name => "public")
    @attr = { :content => "value for content",
      :privacy => @privacy,
      :reminder_date => Time.now.utc.tomorrow 
    }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end
  
  it "should have a reminder date attribute" do
    Micropost.new(@attr).should respond_to(:reminder_date)
  end

  describe "user associations" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end
  
  describe "privacy associations" do

    before(:each) do
      @micropost = @privacy.microposts.create(@attr)
    end

    it "should have a privacy attribute" do
      @micropost.should respond_to(:privacy)
    end

    it "should have the right associated privacy" do
      @privacy.should_not be_nil
      @micropost.privacy.should_not be_nil
      # == @privacy
    end
  end

  describe "validations" do

    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.microposts.build(@attr.merge(:content => "  ")).should_not be_valid
    end

    it "should reject long content" do
      @user.microposts.build(@attr.merge(:content => "a" * 141)).should_not be_valid
    end
    
    it "should require a reminder date" do
      @user.microposts.build(@attr.merge(:reminder_date => nil)).should_not be_valid
    end
    
    it "should require reminder date that is not in the past" do
      @user.microposts.build(@attr.merge(:reminder_date => 2.days.ago)).should_not be_valid
    end
    
    it "should require a future reminder date" do
      @user.microposts.build(@attr).should be_valid
    end
    
    it "should require a privacy" do
      @user.microposts.build(@attr.merge(:privacy => nil)).should_not be_valid
    end
  end

  describe "from_users_followed_by" do
    before(:each) do
      @private_privacy = Privacy.create(:name => "private")
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))
      @user_post = @user.microposts.create!(@attr.merge(:content => "foo"))
      @user_private_post = @user.microposts.create!(@attr.merge(:content => "foo", 
                                                                :privacy => @private_privacy))
      @other_post = @other_user.microposts.create!(@attr.merge(:content => "bar"))
      @third_post = @third_user.microposts.create!(@attr.merge(:content => "baz"))
      @private_post_of_followd_user = 
          @other_user.microposts.create!(@attr.merge(:content => "bac", 
                                                     :privacy => @private_privacy))
      @user.follow!(@other_user)
    end
    it "should have a from_users_followed_by class method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    it "should include the followed user's microposts" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end
    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    it "should not include an unfollowed user's microposts" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
    it "should not include the followed user's microposts that are private" do
      Micropost.from_users_followed_by(@user).should_not include(@private_post_of_followd_user)
    end
    it "should include the user's own private microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_private_post)
    end
  end
end
