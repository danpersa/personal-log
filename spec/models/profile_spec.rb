require 'spec_helper'

describe Profile do
  before(:each) do
    @attr = {
      :name => "George Bush",
      :email =>"george.bush@yahoo.com",
      :location => "United States of America",
      :website => "http://www.george.com"
    }
  end
  
  it "should create a new instance given valid attributes" do
    Profile.create!(@attr)
  end
  
  it "should reject names that are to long" do
    long_name = "a" * 51
    long_name_profile = Profile.new(@attr.merge(:name => long_name))
    long_name_profile.should_not be_valid
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_profile = Profile.new(@attr.merge(:email => address))
      invalid_email_profile.should_not be_valid
    end
  end
  
  it "should reject emails that are to long" do
    long_email = "a" * 256
    long_email_profile = Profile.new(@attr.merge(:email => long_email))
    long_email_profile.should_not be_valid
  end
  
  it "should reject locations that are to long" do
    long_location = "a" * 101
    long_location_profile = Profile.new(@attr.merge(:location => long_location))
    long_location_profile.should_not be_valid
  end
  
  it "should reject websites that are to long" do
    long_website = "a" * 101
    long_website_profile = Profile.new(@attr.merge(:website => long_website))
    long_website_profile.should_not be_valid
  end
end
