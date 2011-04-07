require 'spec_helper'

describe ProfilesController do
  render_views

  before(:each) do
    @base_title = "Remind me to live"
  end

  describe "access control" do

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
        post :update, :user_id => user.id
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      get :edit, :user_id => @user.id
    end
    
    it_should_behave_like "successful get request" do
      let(:action) do
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
