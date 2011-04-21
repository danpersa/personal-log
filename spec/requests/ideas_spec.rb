require 'spec_helper'

describe "Ideas Request" do

  before(:each) do
    user = Factory(:activated_user)
    create_privacies
    visit signin_path
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new idea" do
        lambda do
          visit root_path
          fill_in :idea_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Idea, :count)
      end
    end

    describe "success" do
      
      it "should make a new idea" do
        content = "Lorem ipsum dolor sit amet"
        reminder_date = Time.now.utc
        lambda do
          visit root_path
          fill_in :idea_content, :with => content
          fill_in :reminder_reminder_date, :with => reminder_date
          select "public", :from => "reminder_privacy_id"
          click_button
          response.should have_selector("span.content", :content => content)
        end.should change(Idea, :count).by(1)
      end
    end
  end
end
