require 'spec_helper'

describe RemindersController do
  render_views
  
  describe "access control" do
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        delete :destroy, :id => 1
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
      @idea = Factory(:idea, :user => @user)
      @privacy = Factory(:privacy)
      @reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => @privacy)
    end

    describe "for an unauthorized user" do

      before(:each) do
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
      end

      it "should deny access" do
        delete :destroy, :id => @reminder
        response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do

      before(:each) do
        test_sign_in(@user)
      end

      it "should destroy the idea" do
        lambda do 
          delete :destroy, :id => @reminder
        end.should change(Reminder, :count).by(-1)
      end
    end
  end

end
