require 'spec_helper'

describe IdeaListsController do
  render_views
  
  before(:each) do
    @base_title = "Remind me to live"
  end

  describe "access control" do
    describe "authentication" do
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          post :index
        end
      end
      
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          get :show, :id => 1
        end
      end
  
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          post :create
        end
      end
      
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          put :update, :id => 1
        end
      end
      
      it_should_behave_like "deny access unless signed in" do
        let(:request_action) do
          delete :destroy, :id => 1
        end
      end
    end
    
    describe "own idea list" do
      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @idea_list = Factory(:idea_list, :user => @user)
      end

      it "should deny access if user does not own the idea" do
        get :show, :id => @idea_list
        response.should redirect_to(idea_lists_path)
      end

      it "should deny access if user does not own the idea" do
        put :update, :id => @idea_list
        response.should redirect_to(idea_lists_path)
      end
      
      it "should deny access if user does not own the idea" do
        get :edit, :id => @idea_list
        response.should redirect_to(idea_lists_path)
      end

     it "should deny access if user does not own the idea" do
        delete :destroy, :id => @idea_list
        response.should redirect_to(idea_lists_path)
      end
    end
    
    describe "unexisting idea list" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end
      
      it "should deny access if the idea list does not exist" do
        get :show, :id => 9999
        response.should redirect_to(idea_lists_path)
      end
      
      it "should deny access if the idea list does not exist" do
        put :update, :id => 9999
        response.should redirect_to(idea_lists_path)
      end
      
      it "should deny access if the idea list does not exist" do
        delete :destroy, :id => 9999
        response.should redirect_to(idea_lists_path)
      end
    end
  end
  
  describe "GET 'index'" do
    
    describe "success" do
      before(:each) do
        @user = Factory(:user)
        @idea = Factory(:idea, :user => @user)
        @idea_list = Factory(:idea_list, :user => @idea.user)
        @idea_list_ownership = Factory(:idea_list_ownership, :idea => @idea, :idea_list => @idea_list)
        test_sign_in(@user)
      end
    
      it_should_behave_like "successful get request" do
        let(:action) do
          get :index
          @title = @base_title + " | My idea lists"
        end
      end
      
      it "have an element containing the user's display name" do
        get :index
        response.should have_selector("h1", :content => "My idea lists")
      end
      
      it "have a link containing for creating new idea lists" do
        get :index
        response.should have_selector("a", :content => "Create new idea list" )
      end
      
      it "have a list containing the ideas from the idea list" do
        get :index
        response.should have_selector("a", :content => @idea_list.name)
      end
    end
  end
  
  describe "GET 'show'" do
    
    describe "success" do
      before(:each) do
        @user = Factory(:user)
        @idea = Factory(:idea, :user => @user)
        @idea_list = Factory(:idea_list, :user => @idea.user)
        @idea_list_ownership = Factory(:idea_list_ownership, :idea => @idea, :idea_list => @idea_list)
        test_sign_in(@user)
      end
      
      it_should_behave_like "successful get request" do
        let(:action) do
          get :show, :id => @idea_list
          @title = @base_title + " | Show idea list"
        end
      end
      
      it "have an element containing the user's display name" do
        get :show, :id => @idea_list
        response.should have_selector("span", :content => @user.display_name)
      end
      
      it "have an element containing the user's ideas" do
        get :show, :id => @idea_list
        response.should have_selector("span", :content => @idea.content)
      end
    end
  end
  
  describe "GET 'new'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    it_should_behave_like "successful get request" do
      let(:action) do
        get :new
        @title = @base_title + " | Create idea list"
      end
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "success" do
        
      before(:each) do
        @attr = { :name => "Lorem" }
      end
       
      it "should create an idea list" do
        lambda do
          post :create, :idea_list => @attr
        end.should change(IdeaList, :count).by(1)
      end
    
      it "should redirect to the idea lists page" do
        post :create, :idea_list => @attr
        response.should redirect_to(idea_lists_path)
      end
 
      it "should have a flash message" do
        post :create, :idea_list => @attr
        flash[:success].should =~ /idea list successfully created/i
      end
    end

    describe "failure" do

      before(:each) do
        @attr = { :name => ""}
      end

      it "should not create an idea list without a name" do
        lambda do
          post :create, :idea_list => @attr
        end.should_not change(IdeaList, :count)
      end
      
      it "should not create an a second idea list with the same name, for the same user" do
        lambda do
          post :create, :idea_list =>  { :name => "the list" }
        end.should change(IdeaList, :count)
      
        lambda do
          post :create, :idea_list => { :name => "the list" }
        end.should_not change(IdeaList, :count)
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @idea_list = @user.idea_lists.create!({:name => "name"})
    end

    it_should_behave_like "successful get request" do
      let(:action) do
        get :edit, :id => @idea_list.id
        @title = @base_title + " | Update idea list"
      end
    end
  end
  
  describe "PUT 'update'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @idea_list = @user.idea_lists.create!({:name => "name"})
    end
    
    describe "success" do
        
      before(:each) do
        @attr = { :name => "Lorem" }
      end
       
      it "should update an idea list" do
        put :update, :id => @idea_list.id, :idea_list => @attr
      end
    
      it "should redirect to the idea lists page" do
        put :update, :id => @idea_list.id, :idea_list => @attr
        response.should redirect_to(idea_lists_path)
      end
 
      it "should have a flash message" do
        put :update, :id => @idea_list.id, :idea_list => @attr
        flash[:success].should =~ /idea list successfully updated/i
      end
    end

    describe "failure" do

      before(:each) do
        @attr = { :name => ""}
      end

      it "should not update an idea list without a name" do
        lambda do
          put :update, :id => @idea_list.id, :idea_list => @attr
        end.should_not change(IdeaList, :count)
      end
      
      it "should not create an a second idea list with the same name, for the same user" do
        lambda do
          post :create, :idea_list => { :name => "the list" }
        end.should change(IdeaList, :count)
      
        lambda do
          put :update, :id => @idea_list.id, :idea_list => { :name => "the list" }
        end.should_not change(IdeaList, :count)
      end
    end
  end
  
  describe "DELETE 'destroy'" do

    describe "success" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @idea_list = Factory(:idea_list, :user => @user)
        @idea = Factory(:idea, :user => @user)
        @idea_list_ownership = Factory(:idea_list_ownership, :idea => @idea, :idea_list => @idea_list)
      end

      it "should destroy the idea" do
        lambda do 
          delete :destroy, :id => @idea_list
        end.should change(IdeaList, :count).by(-1)
      end
      
      it "should destroy all it's idea list ownerships" do
        IdeaListOwnership.find_by_idea_list_id(@idea_list.id).should_not be_nil
        delete :destroy, :id => @idea_list
        IdeaListOwnership.find_by_idea_list_id(@idea_list.id).should be_nil
      end
    end
  end
end
