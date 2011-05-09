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
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        get :show, :id => 1
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

    describe "success" do

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

    describe "failure" do

      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @idea = Factory(:idea, :user => @user)
      end

      it "should deny access if user does not own the idea" do
        delete :destroy, :id => @idea
        response.should redirect_to(root_path)
      end
      
      it "should deny access if the idea does not exist" do
        delete :destroy, :id => 9999
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "GET 'show'" do
    
    describe "fail" do

      before(:each) do
        @private_privacy = Factory(:privacy, :name => "private")
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @idea = Factory(:idea, :user => @user)
        @private_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @private_privacy)
      end

      it "should deny access if the user is trying to access other user's private idea" do
        get :show, :id => @idea
        response.should redirect_to(root_path)
      end
      
      it "should deny access if the user is trying to access an unexisting idea" do
        get :show, :id => 99999
        response.should redirect_to(root_path)
      end
      
    end
    
    describe "success" do

      before(:each) do
        @public_privacy = Factory(:privacy)
        @user = Factory(:user)
        @idea = Factory(:idea, :user => @user)
      end

      describe "should allow access" do
        
        before(:each) do
          private_privacy = Factory(:privacy, :name => "private")
          private_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => private_privacy)
        end

        it "to own private idea" do
          test_sign_in(@user)
          get :show, :id => @idea
          response.should be_successful
        end

        it "to another user's public idea" do
          public_reminder = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @public_privacy)
          # now the idea is public
          wrong_user = Factory(:user, :email => Factory.next(:email))
          test_sign_in(wrong_user)
          get :show, :id => @idea
          response.should be_successful
        end  
      end
      
      it "should show the idea" do
        test_sign_in(@user)
        get :show, :id => @idea
        response.should have_selector("span.title", :content => @idea.content)
      end
      
      
      it "should have an element for each user that shares the idea as public" do
        @users = []
        @users << @user
        2.times do
          another_user = Factory(:user, :email => Factory.next(:email))
          @users << another_user
          Factory(:reminder, :user => another_user, :idea => @idea, :privacy => @public_privacy)  
        end
        
        test_sign_in(@user)
        get :show, :id => @idea
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users that share the idea as public" do
        @users = []
        @users << @user
        100.times do
          another_user = Factory(:user, :email => Factory.next(:email))
          @users << another_user
          Factory(:reminder, :user => another_user, :idea => @idea, :privacy => @public_privacy)  
        end
        
        test_sign_in(@user)
        get :show, :id => @idea
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end
      
    end
  end
end
