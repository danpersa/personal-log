shared_examples_for "redirect with flash" do

  before(:each) do
    action
  end

  it "should redirect to path" do
    response.should redirect_to(@path)
  end
  
  it "should have a notification flash message" do
    flash[@notification].should =~ @message
  end
end