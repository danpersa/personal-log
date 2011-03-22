require 'spec_helper'

describe ResetPasswordsController do
  render_views

  describe "GET 'new'" do
    
    before(:each) do
      @base_title = "Personal Log"
    end
    
    it "should be successful" do
      get :new
      response.should be_successful
    end
    
    it "should have the correct title" do
      get :new
      response.should have_selector("title", :content => @base_title + " | Reset Password")
    end
    
    it "should have an email field" do
      get :new
      response.should have_selector("input", :id => "reset_password_email")
    end
    
    it "should not allow access to already logged users" do
      @user = test_sign_in(Factory(:user))
      get :new
      response.should redirect_to(root_path)
      flash[:notice].should =~ /You must not be signed in in order to do this action!/i
    end
  end

  describe "POST 'create'" do
    
    before(:each) do
      @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      @user = Factory(:activated_user)
      ActionMailer::Base.deliveries = []
    end
    
    describe "success" do
      it "should send an email containing the reset password code" do
        post :create, :reset_password => {:email => @user.email}
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.last
        @user = User.find(@user.id)
        email.encoded.should match(@user.password_reset_code)
        response.should redirect_to(signin_path)
        flash[:success].should =~ /The reset password instructions were sent to your email address!/i
      end
      
      it "should redirect to sigin path" do
        post :create, :reset_password => {:email => @user.email}
        response.should redirect_to(signin_path)
      end
      
      it "should have the correct flash message" do
        post :create, :reset_password => {:email => @user.email}
        flash[:success].should =~ /The reset password instructions were sent to your email address!/i
      end

      
      it "should set the reset_password_mail_sent_at field" do
        post :create, :reset_password => {:email => @user.email}
        @user = User.find(@user.id)
        @user.reset_password_mail_sent_at.should_not be_nil
      end
    end
    
    describe "fail" do
      
      it "should not allow access to already logged users" do
        @user = test_sign_in(Factory(:user))
        post :create, :reset_password => {:email => @user.email}
        response.should redirect_to(root_path)
        flash[:notice].should =~ /You must not be signed in in order to do this action!/i
      end
      
      describe "email is not formatted properly" do
        before(:each) do
          @invalid_email_attr = { :email => "emailexample.com" }
        end

        it "should re render the new template" do
          post :create, :reset_password => @invalid_email_attr
          response.should render_template('new')
        end
        
        it "should have the right title" do
          post :create, :reset_password => @invalid_email_attr
          response.should have_selector("title", :content => "Reset Password")
        end
  
        it "should have a flash.now message" do
          post :create, :reset_password => @invalid_email_attr
          response.should have_selector("li", :content => "formatted")
        end
      end
      
      describe "the email does not exist in the database" do
        before(:each) do
          @email_attr = { :email => "email1@example.com" }
        end
        
        it "should re render the new template" do
          post :create, :reset_password => @email_attr
          response.should render_template('new')
        end
        
        it "should have the right title" do
          post :create, :reset_password => @email_attr
          response.should have_selector("title", :content => "Reset Password")
        end
        
        it "should have a flash.now message" do
          post :create, :reset_password => @email_attr
          response.should have_selector("li", :content => "database")
        end
      end
    end
  end
end
