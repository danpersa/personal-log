require 'spec_helper'

describe Profile do
  before(:each) do
    @user = Factory(:activated_user)
    @attr = {
      :name => "George Bush",
      :email =>"george.bush@yahoo.com",
      :location => "United States of America",
      :website => "http://www.george.com"
    }
  end

  it "should create a new instance given valid attributes" do
    profile = Profile.new(@attr)
    profile.user_id = @user.id
    profile.save!
  end

  it "should not reject empty profile" do
    profile = Profile.new(@attr.merge({:email => "", :name => "",
      :location => "", :website => ""}))
    profile.user_id = @user.id
    profile.should be_valid
  end

  it "should reject names that are to long" do
    long_name = "a" * 51
    long_name_profile = Profile.new(@attr.merge(:name => long_name))
    long_name_profile.user_id = @user.id
    long_name_profile.should_not be_valid
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_profile = Profile.new(@attr.merge(:email => address))
      invalid_email_profile.user_id = @user.id
      invalid_email_profile.should_not be_valid
    end
  end

  it "should reject emails that are to long" do
    long_email = "a" * 256
    long_email_profile = Profile.new(@attr.merge(:email => long_email))
    long_email_profile.user_id = @user.id
    long_email_profile.should_not be_valid
  end

  it "should reject locations that are to long" do
    long_location = "a" * 101
    long_location_profile = Profile.new(@attr.merge(:location => long_location))
    long_location_profile.user_id = @user.id
    long_location_profile.should_not be_valid
  end

  it "should reject websites that are to long" do
    long_website = "a" * 101
    long_website_profile = Profile.new(@attr.merge(:website => long_website))
    long_website_profile.user_id = @user.id
    long_website_profile.should_not be_valid
  end

  describe "user association" do

    it "should have a profile attribute" do
      @user.should respond_to(:profile)
    end

    it "should have the right associated user" do
      profile = Profile.new(@attr)
      profile.user_id = @user.id
      profile.save!
      @user.reload
      @user.profile.should_not be_nil
      @user.profile.should == profile
    end
  end

  describe "empty method" do

    it "should have an empty method" do
      profile = Profile.new(@attr)
      profile.user_id = @user.id
      profile.save!
      profile.should respond_to('empty?')
    end

    it "should be empty" do
      profile = Profile.new({:email => "", :name => "",
        :location => "", :website => ""})
      profile.user_id = @user.id
      profile.should be_empty
    end
    
    it "should be empty" do
      profile = Profile.new({:email => "", :name => "",
        :location => "", :website => ""})
      profile.should be_empty
    end
    
    it "should not be empty" do
      profile = Profile.new(@attr)
      profile.should_not be_empty
    end
  end
end
