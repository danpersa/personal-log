require 'spec_helper'

describe RemindersController do
  render_views
  
  describe "access control" do
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        delete :destroy, :id => 1
      end
    end
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        get :remind_me_too, :idea_id => 1
      end
    end
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        post :create
      end
    end
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        post :create_reminder_and_idea
      end
    end
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        post :create_from_users_sharing_idea
      end
    end
    
    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        get :index
      end
    end
  end
  
  describe "GET 'remind_me_too'" do
    
    before(:each) do
      @user = Factory(:user)
      @idea = Factory(:idea, :user => @user)
    end
    
    describe "success" do
      
      it "should display the requested public idea" do
        test_sign_in(Factory(:user, :email => "user@example.net"))
        privacy = Factory(:privacy)
        reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => privacy)  
        get :remind_me_too, :idea_id => @idea.id
        response.should render_template :remind_me_too
      end
      
      it "should display the requested own private idea" do
        test_sign_in(@user)
        privacy = Factory(:privacy, :name => "private")
        reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => privacy)  
        get :remind_me_too, :idea_id => @idea.id
        response.should render_template :remind_me_too
      end
    end
    
    describe "failure" do
      
      describe "idea is not public and not your own" do
        
        it_should_behave_like "redirect with flash" do
          let(:action) do
            test_sign_in(Factory(:user, :email => "user@example.net"))
            private_privacy = Factory(:privacy, :name => "private")
            # we create a private idea
            reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => private_privacy)
            get :remind_me_too, :idea_id => @idea.id
            @notification = :error
            @message = /You want to remind an idea that does not exist!/
            @path = root_path
          end
        end
      end
    end
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      @user = Factory(:user)
      @idea = Factory(:idea, :user => @user)
    end
    
    describe "success" do
      
      describe "public idea" do
        
        before(:each) do
          test_sign_in(Factory(:user, :email => "user@example.net"))
          public_privacy = Factory.create(:privacy)
          Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => public_privacy)
          # we create a private idea
          @reminder_attr = { :reminder_date => future_date, :privacy_id => public_privacy }
          @idea_attr = { :id => @idea.id}
        end
      
        it "should create a new reminder" do
          lambda do
            post :create, :idea => @idea_attr, :reminder => @reminder_attr
          end.should change(Reminder, :count).by(1)
        end
        
        it_should_behave_like "redirect with flash" do
          let(:action) do
            post :create, :idea => @idea_attr, :reminder => @reminder_attr
            @notification = :success
            @message = /Reminder successfully created!/
            @path = root_path
          end
        end
        
      end
      
      describe "own idea" do
        
        before(:each) do
          test_sign_in(@user)
          private_privacy = Factory(:privacy, :name => "private")
          reminder = Factory(:reminder, :user => @user, :idea => @idea, :created_at => 1.day.ago, :privacy => private_privacy)
          # we create a private idea
          @reminder_attr = { :reminder_date => future_date, :privacy_id => private_privacy }
          @idea_attr = { :id => @idea.id}
        end
      
        it "should create a new reminder" do
          lambda do
            post :create, :idea => @idea_attr, :reminder => @reminder_attr
          end.should change(Reminder, :count).by(1)
        end
        
        it_should_behave_like "redirect with flash" do
          let(:action) do
            post :create, :idea => @idea_attr, :reminder => @reminder_attr
            @notification = :success
            @message = /Reminder successfully created!/
            @path = root_path
          end
        end
      end
    end
    
    describe "failure" do
      describe "idea is not public and not your own" do
        it_should_behave_like "redirect with flash" do
          let(:action) do
            test_sign_in(Factory(:user, :email => "user@example.net"))
            private_privacy = Factory(:privacy, :name => "private")
            # we create a private idea
            reminder_attr = { :reminder_date => future_date, :privacy => private_privacy }
            idea_attr = { :id => @idea.id}
            post :create, :idea => idea_attr, :reminder => reminder_attr
            @notification = :error
            @message = /You want to remind an idea that does not exist!/
            @path = root_path
          end
        end
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
  
  describe "GET 'index'" do
    
    describe "success" do
      
      before(:each) do
        @user = Factory(:user)
      end
      
      it "should return a response" do
        test_sign_in @user
        get :index
        response.should be_successful
      end
      
      it "should have a next and a previous month" do
        create_privacies
        test_web_sign_in @user
        visit reminders_path
        page.should have_link(">") 
        page.should have_link("<")
      end
      
    end
    
  end
end
