require 'spec_helper'

describe "Remind me too Request" do

  before(:each) do
    user = Factory(:activated_user)
    @idea = Factory(:idea, :user => user)
    public_privacy = Factory(:privacy)
    @reminder = Factory(:reminder, :user => user, :idea => @idea, :created_at => 1.day.ago, :privacy => public_privacy)
    visit signin_path
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new reminder if not valid" do
        lambda do
          visit remind_me_too_path(:idea_id => @idea.id )
          fill_in :reminder_reminder_date, :with => ""
          select "public", :from => "reminder_privacy_id"
          click_button
          response.should render_template('reminders/remind_me_too')
          response.should have_selector("div#error_explanation")
        end.should_not change(Reminder, :count)
      end
      
      it "should redirect to home if the idea is private" do
        @reminder.privacy = Factory(:privacy, :name => "private")
        @reminder.save!
        user = Factory(:activated_user, :email => "next@user.com")
        @idea.user = user
        @idea.save!
        visit remind_me_too_path(:idea_id => @idea.id )
        response.should have_selector("div.flash.error", :content => "You want to remind")
      end
    end

    describe "success" do
      
      it "should make a new reminder" do
        reminder_date = "01/02/2020"
        lambda do
          visit remind_me_too_path(:idea_id => @idea.id )
          fill_in :reminder_reminder_date, :with => reminder_date
          select "public", :from => "reminder_privacy_id"
          click_button
        end.should change(Reminder, :count).by(1)
      end
      
      it "should display a flash message" do
        reminder_date = "01/02/2020"
        visit remind_me_too_path(:idea_id => @idea.id )
        fill_in :reminder_reminder_date, :with => reminder_date
        select "public", :from => "reminder_privacy_id"
        click_button
        response.should have_selector("div.flash.success", :content => "Reminder")
      end
    end
  end
end
