require 'spec_helper'

describe ProfilesController do
  render_views

  before(:each) do
    @base_title = "Remind me to live"
  end

  describe "access control" do
    describe "authentication" do
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          user = Factory(:activated_user)
          get :edit, :user_id => user.id
        end
      end
  
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          user = Factory(:activated_user)
          post :create, :user_id => user.id
        end
      end
  
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          user = Factory(:activated_user)
          put :update, :user_id => user.id
        end
      end
    end
    
    describe "the requested user is not the logged user" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end
    
      it "should not allow access for edit" do
        another_user = Factory(:user, :email => "other@yahoo.com")
        get :edit, :user_id => another_user, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
      
      it "should not allow access for create" do
        another_user = Factory(:user, :email => "other@yahoo.com")
        post :create, :user_id => another_user, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
      
      it "should not allow access for update" do
        another_user = Factory(:user, :email => "other@yahoo.com")
        put :update, :user_id => another_user, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
    end
    
    describe "the user does not exist" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end
      
      it "should not edit" do
        get :edit, :user_id => 999999
        response.should redirect_to(user_profile_path(@user))
      end
      
      it "should not create" do
        post :create, :user_id => 999999, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
      
            
      it "should not update" do
        put :update, :user_id => 999999, :profile => @attr
        response.should redirect_to(user_profile_path(@user))
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :edit, :user_id => @user.id
        @title = @base_title + " | Update public profile"
      end
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @attr = {:email => "", :name => "",
                 :location => "", :website => ""}
    end

    describe "failure" do
      
      it "should not create a profile with empty fields" do
        lambda do
          post :create, :user_id => @user.id, :profile => @attr
        end.should_not change(Profile, :count)
      end
      
      describe "invalid email" do
      
        it "should not create a profile" do
          lambda do
            post :create, :user_id => @user.id, 
                 :profile => @attr.merge({:email => "dan"})
          end.should_not change(Profile, :count)
        end
        
        it "should render the edit template" do
          post :create, :user_id => @user.id, 
               :profile => @attr.merge({:email => "dan"})
          response.should render_template(:edit)
        end
      end
    end

    describe "success" do
      
      it "should create a profile" do
        lambda do
          post :create, :user_id => @user.id, 
               :profile => @attr.merge({:email => "dan@yahoo.com"})
        end.should change(Profile, :count).by(1)
      end
      
      describe "successful creation of a profile" do
        it_should_behave_like "redirect with flash" do
          let(:action) do
            post :create, :user_id => @user.id,
               :profile => @attr.merge({:email => "dan@yahoo.com"})
            @notification = :success
            @message = /profile successfully updated/i
            @path = user_profile_path(@user)
          end
        end
      end
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @profile = Factory(:profile)
      @user = @profile.user
      test_sign_in(@user)
      @attr = {:email => "", :name => "",
                 :location => "", :website => ""}
    end
    
    describe "failure" do
      
      it "should destroy a profile with empty fields" do
        lambda do
          put :update, :user_id => @user.id, :profile => @attr
        end.should change(Profile, :count).by(-1)
      end
      
      describe "invalid email" do
        
        it "should not change the email profile" do
          put :update, :user_id => @user.id, 
            :profile => @attr.merge({:email => "dan"})
          @profile.reload
          @profile.email.should_not == "dan"
        end
        
        it "should render the edit template" do
          put :update, :user_id => @user.id, 
            :profile => @attr.merge({:email => "dan"})
          response.should render_template(:edit)
        end
      end
    end
    
    describe "success" do
      
      it "should change the profile" do
        put :update, :user_id => @user.id, 
            :profile => @attr.merge({:email => "dan@yahoo.com"})
        @profile.reload
        @profile.email.should == "dan@yahoo.com"
      end
      
      describe "successful update of a profile" do
        it_should_behave_like "redirect with flash" do
          let(:action) do
            put :update, :user_id => @user.id, 
            :profile => @attr.merge({:email => "dan@yahoo.com"})
            @notification = :success
            @message = /profile successfully updated/i
            @path = user_profile_path(@user)
          end
        end
      end
    end
  end
end
