require 'spec_helper'

describe ChangePasswordsController do
  render_views

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:activated_user)
    end

    describe "success" do
      before(:each) do
        @user.reset_password
        get :edit, :id => @user.password_reset_code
      end

      it "should allow access without sign in" do
        response.should_not redirect_to(signin_path)
      end
      
      it "should render the edit template" do
        response.should render_template :edit
      end
    end

    describe "fail" do
      it "should redirect to home page if signed in" do
        @user.reset_password
        test_sign_in(@user)
        get :edit, :id => @user.password_reset_code
        response.should redirect_to(root_path)
      end
      
      describe "incorrect password_reset_code" do
        
        let(:action) do
          get :edit, :id => "wrongpasswordresetcode"
          @notification = :notice
          @message = /You don't have a valid reset password link!/
          @path = signin_path
        end
        
        it_behaves_like "redirect with flash"
      end
      
      describe "it should reject expired links" do
         
        let(:action) do
          @user.reset_password
          @user.reset_password_mail_sent_at = 2.days.ago
          @user.save!
          get :edit, :id => @user.password_reset_code
          @notification = :notice
          @message = /Your reset password link has expired! Please use the reset password feature again!/
          @path = reset_passwords_path
        end
      
        it_behaves_like "redirect with flash"
      end
    end
    
    describe "it should reject users that are not activated" do
      let(:action) do
          user = Factory(:user)
          user.reset_password
          get :edit, :id => user.password_reset_code
          @notification = :notice
          @message = /You cannot reset password for an user that is not activated! Please activate the user first!/
          @path = signin_path
        end
      
        it_behaves_like "redirect with flash"
    end
  end

  describe "POST 'update'" do

    before(:each) do
      @user = Factory(:activated_user)
      @user.reset_password
      @attr = { :password_reset_code => @user.password_reset_code, 
                :password => "password",
                :password_confirmation => "password" }
    end

    describe "success" do
      
      before(:each) do
        post :create, :change_password => @attr
      end
      
      let(:action) do
        @notification = :success
        @message = /Your password was successfully changed!/
        @path = signin_path
      end
      
      it_behaves_like "redirect with flash"
      
      it "should not allow to use the same password twice" do
        post :create, :change_password => @attr
        flash[:notice].should =~ /You don't have a valid reset password link!/
      end
      
    end

    describe "fail" do
      
      it "should validate password" do
        post :create, :change_password => @attr.merge(:password_confirmation => "another")
        response.should render_template :edit
      end
      
      describe "it should reject expired links" do
         
        let(:action) do
          @user.reset_password_mail_sent_at = 2.days.ago
          @user.save!
          post :create, :change_password => @attr
          @notification = :notice
          @message = /Your reset password link has expired! Please use the reset password feature again!/
          @path = reset_passwords_path
        end
      
        it_behaves_like "redirect with flash"
      end
      
      describe "wrong password_reset_code" do
        
        let(:action) do
          post :create, :change_password => @attr.merge(:password_reset_code => "another")
          @notification = :notice
          @message = /ou don't have a valid reset password link!/
          @path = signin_path
        end
      
        it_behaves_like "redirect with flash"
      end
      
      describe "signed in" do
        let(:action) do
          test_sign_in(@user)
          post :create, :change_password => @attr
          @notification = :notice
          @message = /You must not be signed in in order to do this action!/
          @path = root_path
        end
      
        it_behaves_like "redirect with flash"
      end
    end
  end
end
