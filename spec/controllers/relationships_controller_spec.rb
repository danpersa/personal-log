require 'spec_helper'

describe RelationshipsController do
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
      @followed = Factory(:user, :email => Factory.next(:email))
    end
    
    it "should create a relationship" do
      lambda do
        post :create, :relationship => { :followed_id => @followed }
        response.should be_redirect
      end.should change(Relationship, :count).by(1)
    end
    
    it "should create a relationship using Ajax" do
      lambda do
        xhr :post, :create, :relationship => { :followed_id => @followed }
        response.should be_success
      end.should change(Relationship, :count).by(1)
    end
  end
  describe "DELETE 'destroy'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email => Factory.next(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end
    
    it "should destroy a relationship" do
      lambda do
        delete :destroy, :id => @relationship
        response.should be_redirect
      end.should change(Relationship, :count).by(-1)
    end
    
    it "should destroy a relationship using Ajax" do
      lambda do
        xhr :delete, :destroy, :id => @relationship
        response.should be_success
      end.should change(Relationship, :count).by(-1)
    end
  end
end
