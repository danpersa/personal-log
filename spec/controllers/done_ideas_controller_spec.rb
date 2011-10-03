require 'spec_helper'

describe DoneIdeasController do
  render_views
  
  describe "POST 'create'" do

    before(:each) do
      @user = Factory.create(:user)
      @idea = Factory.create(:idea, :user => @user)
      test_sign_in(@user)
    end
    
    describe "success" do
       
      it "should create a done idea" do
        lambda do
          post :create, :id => @idea.id
        end.should change(DoneIdea, :count).by(1)
      end
    end
  end
  
  
  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory.create(:user)
      @idea = Factory.create(:idea, :user => @user)
      @done_idea = Factory.create(:done_idea, :idea => @idea, :user => @user)
      test_sign_in(@user)
    end
    
    describe "success" do
       
      it "should destroy a done idea" do
        lambda do
          delete :destroy, :id => @idea.id
        end.should change(DoneIdea, :count).by(-1)
      end
    end
  end
end
