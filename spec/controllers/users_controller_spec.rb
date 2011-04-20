require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    # Define @base_title here.
    @base_title = "Remind me to live"
  end

  describe "GET 'index'" do

    it_should_behave_like "deny access unless signed in" do
      let(:request_action) do
        get :index
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "another@example.com")
        third  = Factory(:user, :email => "another@example.net")
        @users = [@user, second, third]
      end
      
      it_should_behave_like "successful get request" do
        let(:action) do
          get :index
          @title = @base_title + " | All users"
        end
      end

      it "should have an element for each user" do
        get :index
         @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end
    end
  end

  describe "GET 'new'" do
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :new
        @title = @base_title + " | Sign up"
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
      @privacy = Factory(:privacy)
      @private_privacy = Factory(:privacy, :name => "private")
    end
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :show, :id => @user
        @title = @base_title + " | " + @user.name
      end
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
    
    it "should show the user's reminders" do
      idea1 = Factory(:idea, :user => @user, :content => "Foo bar", :privacy => @privacy)
      idea2 = Factory(:idea, :user => @user, :content => "Baz quux", :privacy => @privacy)
      
      reminder1 = Factory(:reminder, :user => @user, :idea => idea1, :created_at => 1.day.ago, :privacy => @privacy)
      reminder2 = Factory(:reminder, :user => @user, :idea => idea2, :created_at => 2.day.ago, :privacy => @privacy)
      
      get :show, :id => @user
      response.should have_selector("span.content", :content => idea1.content)
      response.should have_selector("span.content", :content => idea2.content)
    end
    
    it "should not show private reminders" do
      public_idea = Factory(:idea, :user => @user, :content => "Foo bar", :privacy => @privacy)
      private_idea = Factory(:idea, :user => @user, :content => "Baz quux", :privacy => @private_privacy)
      
      public_reminder = Factory(:reminder, :user => @user, :idea => public_idea, :created_at => 1.day.ago, :privacy => @privacy)
      private_reminder = Factory(:reminder, :user => @user, :idea => private_idea, :created_at => 2.day.ago, :privacy => @private_privacy)
      
      get :show, :id => @user
      response.should have_selector("span.content", :content => public_idea.content)
      response.should_not have_selector("span.content", :content => private_idea.content)
    end
    
    it "should paginate" do
        32.times do
          idea = Factory(:idea, :user => @user, :content => "Baz quux", :privacy => @privacy)
          Factory(:reminder, :user => @user, :idea => idea, :created_at => 2.day.ago, :privacy => idea.privacy)
        end
        get :show, :id => @user
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users/#{@user.id}?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users/#{@user.id}?page=2",
                                           :content => "Next")
    end
    
    describe "for logged users" do
      before(:each) do
        @public_idea = Factory(:idea, :user => @user, :content => "Foo bar", :privacy => @privacy)
        @private_idea = Factory(:idea, :user => @user, :content => "Baz quux", :privacy => @private_privacy)
        @public_reminder = Factory(:reminder, :user => @user, :idea => @public_idea, :created_at => 1.day.ago, :privacy => @privacy)
        @private_reminder = Factory(:reminder, :user => @user, :idea => @private_idea, :created_at => 2.day.ago, :privacy => @private_privacy)
      end
      
      
      it "should show own private posts" do
        test_sign_in(@user)
        get :show, :id => @user
        response.should have_selector("span.content", :content => @public_idea.content)
        response.should have_selector("span.content", :content => @private_idea.content)
      end
      
      it "should not show other user's private posts" do
        other_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(other_user)
        get :show, :id => @user
        response.should have_selector("span.content", :content => @public_idea.content)
        response.should_not have_selector("span.content", :content => @private_idea.content)
      end
    end
  end

  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template :new
      end
      
      it "should not send any mail" do
        ActionMailer::Base.deliveries = []
        post :create, :user => @attr
        ActionMailer::Base.deliveries.should be_empty
      end
      
      it "should validate the password" do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz1" }
        post :create, :user => @attr
        response.should render_template :new
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the signin page" do
        post :create, :user => @attr
        response.should redirect_to(signin_path)
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /please follow the steps from the email we sent you to activate your account/i
      end

      it "should NOT sign the user in" do
        post :create, :user => @attr
        controller.should_not be_signed_in
      end
      
      it "should send registration confirmation any mail" do
        ActionMailer::Base.deliveries = []
        post :create, :user => @attr
        ActionMailer::Base.deliveries.should_not be_empty
        email = ActionMailer::Base.deliveries.last
        email.to.should == [@attr[:email]]
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it_should_behave_like "successful get request" do
      let(:action) do
        get :edit, :id => @user
        @title = @base_title + " | Edit user"
      end
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:activated_user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template :edit
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
      
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end
      
      it "should not change the user's password" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.has_password?("foobar").should == true
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          get :edit, :id => @user
        end
      end

      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          put :update, :id => @user, :user => {}
        end
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end

  describe "follow pages" do
    describe "when not signed in" do
      
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          get :following, :id => 1
        end
      end
      
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          get :followers, :id => 1
        end
      end
    end
    
    describe "when signed in" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      
      it "should show user following" do
        get :following, :id => @user
        response.should have_selector("a", :href => user_path(@other_user),
            :content => @other_user.name)
      end
      
      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user),
            :content => @user.name)
      end
    end
  end

  describe "GET 'activate'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "when signed in" do
      it "should redirect to profile if correct activation code" do
        test_sign_in(@user)
        get :activate, :activation_code => @user.activation_code
        response.should redirect_to(users_path + "/#{@user.id}")
      end
      
      it "should redirect to profile if incorrect activation code or empty" do
        test_sign_in(@user)
        get :activate, :activation_code => 123
        response.should redirect_to(users_path + "/#{@user.id}")
      end
    end

    describe "when not signed in" do
      
      describe "when activation code is empty or not valid" do
        it "should redirect to signin path" do
         get :activate, :activation_code => 123
         response.should redirect_to(signin_path)  
        end
      end

      describe "when the user is already activated" do

        it "should render an already activated user message" do
          test_activate_user(@user)
          get :activate, :activation_code => @user.activation_code
          @user.reload
          @user.activated?.should be_true
          response.should redirect_to(signin_path)
          flash[:notice].should =~ /Your account has already been activated!/i
        end  
      end
      
      describe "when the user not is activated" do
        
        it "should activate the user and redirect to home pabe" do
          get :activate, :activation_code => @user.activation_code
          @user.reload
          @user.activated?.should be_true
          response.should redirect_to(root_path)
        end
      end
    end
  end
end