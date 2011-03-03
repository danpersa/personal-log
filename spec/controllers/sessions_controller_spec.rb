require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign in")
    end
  end


  describe "POST 'create'" do

    describe "invalid signin" do

      describe "invalid email and password" do
        
        before(:each) do
          @attr = { :email => "email@example.com", :password => "invalid" }
        end
  
        it "should re-render the new page" do
          post :create, :session => @attr
          response.should render_template('new')
        end
  
        it "should have the right title" do
          post :create, :session => @attr
          response.should have_selector("title", :content => "Sign in")
        end
  
        it "should have a flash.now message" do
          post :create, :session => @attr
          flash.now[:error].should =~ /invalid/i
        end
      end
      
      describe "valid email but invalid password" do
        
        before(:each) do
          @user = Factory(:activated_user)
          @attr = { :email => @user.email, :password => @user.password }
        end
        
        it "should not be created with a blank password" do
          post :create, :session => @attr.merge(:password => "")
          response.should render_template('new')
        end
      end
      
    end

    describe "with valid email and password" do

      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end

      it "should not sign the user in if the user is not activated" do
        post :create, :session => @attr
        # Fill in with tests for a signed-in user.
        controller.current_user.should == nil
        controller.should_not be_signed_in
        response.should redirect_to(signin_path)
      end

      it "should sign the user in if the user is activated" do
        test_activate_user @user
        post :create, :session => @attr
        # Fill in with tests for a signed-in user.
        controller.current_user.should == @user
        controller.should be_signed_in
      end

      it "should redirect to the user show page" do
        test_activate_user @user
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end
    end
  end

  describe "DELETE 'destroy'" do

    it "should sign a user out" do
      test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end
