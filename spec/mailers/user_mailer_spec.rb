require "spec_helper"

describe UserMailer do
  describe "send registration confirmation" do
    before(:each) do
      ActionMailer::Base.deliveries = []
      @user = Factory(:user)
      @email = UserMailer.registration_confirmation(@user).deliver
    end

    it "should send an email" do
      ActionMailer::Base.deliveries.should_not be_empty
    end
    
    it "should be sent to the correct user" do
      @email.to.should == [@user.email]
    end
    
    it "should have the correct subject" do
      @email.subject.should == "Registered"
    end
    
    it "should containt the correct activation code" do
      @email.encoded.should match(@user.activation_code)
    end
  end
end
