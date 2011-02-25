require 'spec_helper'

describe UserObserver do
  
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
    ActionMailer::Base.deliveries = []
  end
  
  it "should send a mail when the user is created" do
    User.create(@attr)
    ActionMailer::Base.deliveries.should_not be_empty
  end
  
  it "should not send a mail if validation fails" do
    User.create(@attr.merge :password_confirmation => "foo")
    ActionMailer::Base.deliveries.should be_empty
  end
end
