shared_examples_for "password validation" do

  before(:each) do
    action
  end

  it "should require a password" do
    @class.new(@attr.merge(:password => "", :password_confirmation => "")).
    should_not be_valid
  end

  it "should require a matching password confirmation" do
    @class.new(@attr.merge(:password_confirmation => "invalid")).
    should_not be_valid
  end

  it "should reject short passwords" do
    short = "a" * 5
    hash = @attr.merge(:password => short, :password_confirmation => short)
    @class.new(hash).should_not be_valid
  end

  it "should reject long passwords" do
    long = "a" * 41
    hash = @attr.merge(:password => long, :password_confirmation => long)
    @class.new(hash).should_not be_valid
  end
end