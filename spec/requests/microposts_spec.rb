require 'spec_helper'

describe "Microposts" do

  before(:each) do
    user = Factory(:activated_user)
    visit signin_path
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new micropost" do
        create_privacies
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end
    end

    describe "success" do
      
      before(:each) do
        Privacy.create(:name => "public")
        Privacy.create(:name => "private")
      end

      it "should make a new micropost" do
        content = "Lorem ipsum dolor sit amet"
        reminder_date_year = Time.now.year.next
        lambda do
          visit root_path
          fill_in :micropost_content, :with => content
          fill_in :micropost_reminder_date_1i, :with => reminder_date_year
          select "public", :from => "micropost_privacy_id"
          click_button
          response.should have_selector("span.content", :content => content)
        end.should change(Micropost, :count).by(1)
      end
    end
  end
end
