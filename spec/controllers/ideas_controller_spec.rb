require 'spec_helper'

describe IdeasController do
  render_views

  describe "access control" do

    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        post :create
      end
    end
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        delete :destroy, :id => 1
      end
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe "failure" do

      before(:each) do
        @privacy = Factory(:privacy)
        @attr = { :content => ""}
        @reminder_attr = { :reminder_date => Time.now.utc.tomorrow, :privacy => @privacy }
      end

      it "should not create an idea without content" do
        lambda do
          post :create, :idea => @attr, :reminder => @reminder_attr
        end.should_not change(Idea, :count)
      end
      
      it "should not create an idea without a reminder" do
        lambda do
          post :create, :idea => @attr.merge(:content => "content")
        end.should_not change(Idea, :count)
      end

      it "should render the home page" do
        post :create, :idea => @attr, :reminder => @reminder_attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do
        
      before(:each) do
        @privacy = Factory(:privacy)
        @attr = { :content => "Lorem ipsum" }
        @reminder_attr = { :reminder_date => Time.now.utc.tomorrow, :privacy => @privacy }
      end
       
      it "should create an idea" do
        lambda do
          post :create, :idea => @attr, :reminder => @reminder_attr
        end.should change(Idea, :count).by(1)
      end
    
      it "should redirect to the home page" do
        post :create, :idea => @attr, :reminder => @reminder_attr
        response.should redirect_to(root_path)
      end
 
      it "should have a flash message" do
        post :create, :idea => @attr, :reminder => @reminder_attr
        flash[:success].should =~ /idea created/i
      end
    end
  end

  describe "DELETE 'destroy'" do

    describe "for an unauthorized user" do

      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @idea = Factory(:idea, :user => @user)
      end

      it "should deny access" do
        delete :destroy, :id => @idea
        response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do

      before(:each) do
        @privacy = Factory(:privacy)
        @user = test_sign_in(Factory(:user))
        @idea = Factory(:idea, :user => @user)
        @reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => @privacy)
      end

      it "should destroy the idea" do
        lambda do 
          delete :destroy, :id => @idea
        end.should change(Idea, :count).by(-1)
      end
      
      it "should destroy all it's reminders" do
        Reminder.find_by_idea_id(@idea.id).should_not be_nil
        delete :destroy, :id => @idea
        Reminder.find_by_idea_id(@idea.id).should be_nil
      end
    end
  end
end
