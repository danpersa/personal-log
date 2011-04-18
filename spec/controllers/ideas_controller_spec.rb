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
        @attr = { :content => "", :privacy => @privacy }
      end

      it "should not create a idea without content" do
        lambda do
          post :create, :idea => @attr
        end.should_not change(Idea, :count)
      end
      
      it "should not create a idea without privacy" do
        lambda do
          post :create, :idea => @attr.merge({:content => "valid content", :privacy => nil})
        end.should_not change(Idea, :count)
      end

      it "should render the home page" do
        post :create, :idea => @attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do
        
      before(:each) do
        @privacy = Factory(:privacy)
        @attr = { :content => "Lorem ipsum", 
          :reminder_date => Time.now.utc.tomorrow,
          :privacy => @privacy 
          }
      end
       
      it "should create a idea" do
        lambda do
          post :create, :idea => @attr
        end.should change(Idea, :count).by(1)
      end
    
      it "should redirect to the home page" do
        post :create, :idea => @attr
        response.should redirect_to(root_path)
      end
 
      it "should have a flash message" do
        post :create, :idea => @attr
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
        @user = test_sign_in(Factory(:user))
        @idea = Factory(:idea, :user => @user)
      end

      it "should destroy the idea" do
        lambda do 
          delete :destroy, :id => @idea
        end.should change(Idea, :count).by(-1)
      end
    end
  end
end
