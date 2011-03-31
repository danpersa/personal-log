require 'spec_helper'

describe ChangePassword do
  before(:each) do
    @attr = {
      :password => "password",
      :password_confirmation => "password",
      :password_reset_code => "abcdefg"
    }
  end

  it "should create a new valid instance given valid attributes" do
    change_password = ChangePassword.new(@attr)
    change_password.should be_valid
  end

  it_behaves_like "password validation" do
    let(:action) do
      @class = ChangePassword
    end
  end
end
