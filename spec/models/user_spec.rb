require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject emails that are to long" do
    long_email = "a" * 256 + "@yahoo.com"
    long_email_user = User.new(@attr.merge(:email => long_email))
    long_email_user.should_not be_valid
  end

  it "should reject duplicate email addresses" do
  # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should not permit states that are not defined" do
    user_with_invalid_state = User.create!(@attr)
    user_with_invalid_state.state = "invalid_state"
    user_with_invalid_state.should_not be_valid
  end
  
  it_should_behave_like "password validation" do
    let(:action) do
      @valid_object = User.new(@attr)
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end
      
      it "should return nil if user is blocked" do
        blocked_user = Factory(:activated_user, :email => "blocked@yahoo.com")
        blocked_user.block!
        blocked_user = User.authenticate(blocked_user.email, blocked_user.password)
        blocked_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "idea associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:idea, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a ideas attribute" do
      @user.should respond_to(:ideas)
    end

    it "should have the right ideas in the right order" do
      @user.ideas.order("ideas.created_at DESC").should == [@mp2, @mp1]
    end
  end
  
  describe "idea list associations" do

    before(:each) do
      @user = User.create(@attr)
      @idea_list1 = Factory(:idea_list, :user => @user)
      @idea_list2 = Factory(:idea_list, :user => @user, :name => "name 1")
    end

    it "should have a idea_lists attribute" do
      @user.should respond_to(:idea_lists)
    end

    it "should have the right idea lists" do
      @user.idea_lists.should == [@idea_list1, @idea_list2]
    end
  end
  
  describe "reminder associations" do
    before(:each) do
      @privacy = Factory(:privacy)
      @user = User.create(@attr)
      @other_user = Factory(:user, :email => Factory.next(:email))
      @idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      @reminder1 = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @privacy, :created_at => 1.day.ago)
      @reminder2 = Factory(:reminder, :user => @user, :idea => @idea, :privacy => @privacy, :created_at => 1.hour.ago)
    end
    
    it "should have a reminders attribute" do
      @user.should respond_to(:reminders)
    end
    
    it "should have the right reminders in the right order" do
      @user.reminders.order("reminders.created_at DESC").should == [@reminder2, @reminder1]
    end
    
    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's idea" do
        @user.feed.should include(@idea)
      end
      
      it "should not include a different user's ideas" do
        idea1 = Factory(:idea, :user => @other_user, :created_at => 1.day.ago)
        reminder3 = Factory(:reminder,
            :user => @other_user,
            :idea => idea1,
            :privacy => @privacy)
        @user.feed.should_not include(idea1)
      end
      
      it "should include the public ideas of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        idea1 = Factory(:idea, :user => followed, :created_at => 1.day.ago)
        reminder3 = Factory(:reminder, :user => followed, :idea => idea1, :privacy => @privacy)
        @user.follow!(followed)
        @user.feed.should include(idea1)
      end
      
      it "should not include the private ideas of followed users" do
        private_privacy = Factory(:privacy, :name => "private")
        followed = Factory(:user, :email => Factory.next(:email))
        idea1 = Factory(:idea, :user => followed, :created_at => 1.day.ago)
        reminder3 = Factory(:reminder, :user => followed, :idea => idea1, :privacy => private_privacy)
        @user.follow!(followed)
        @user.feed.should_not include(idea1)
      end
    end
  end
  
  describe ":ideas_marked_as_good association" do
    before(:each) do
      @user = User.create(@attr)
      @idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)   
      @other_idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)         
      Factory(:good_idea, :user => @user, :idea => @idea)
      Factory(:good_idea, :user => @user, :idea => @other_idea)
    end
    
    it "should have a ideas_marked_as_good attribute" do
      @user.should respond_to(:ideas_marked_as_good)
    end
    
    it "should have two associated users" do
      @user.ideas_marked_as_good.all.size.should == 2
    end
  end
  
  describe "good ideas associations" do

    before(:each) do
      @user = User.create(@attr)
      @idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)   
    end

    it "should have a good ideas attribute" do
      @user.should respond_to(:good_ideas)
    end

    it "should have the right associated good_idea" do
      @good_idea = @user.good_ideas.create({:idea => @idea})
      GoodIdea.first.user_id.should == @user.id
      GoodIdea.first.user.should == @user
    end
    
    it "should destroy associated good ideas" do
      @good_idea = @user.good_ideas.create({:idea => @idea})
      create_community_user
      @user.destroy
      GoodIdea.find_by_id(@good_idea.id).should be_nil
    end
    
    it "should have a marked_as_good? method" do
      @user.should respond_to(:marked_as_good?)
    end

    it "should have a mark_as_good! method" do
      @user.should respond_to(:mark_as_good!)
    end

    it "should have a unmark_as_good! method" do
      @user.should respond_to(:unmark_as_good!)
    end

    it "should mark an idea as good" do
      @user.mark_as_good!(@idea)
      @user.should be_marked_as_good(@idea)
    end

    it "should include the idea marked as good in the ideas marked as good array" do
      @user.mark_as_good!(@idea)
      @user.ideas_marked_as_good.should include(@idea)
    end

    it "should unmark an idea as good" do
      @user.mark_as_good!(@idea)
      @user.unmark_as_good!(@idea)
      @user.should_not be_marked_as_good(@idea)
    end
  end
  
  describe "done ideas associations" do

    before(:each) do
      @user = User.create(@attr)
      @idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)   
    end

    it "should have a done ideas attribute" do
      @user.should respond_to(:done_ideas)
    end

    it "should have the right associated done idea" do
      @done_idea = @user.done_ideas.create({:idea => @idea})
      DoneIdea.first.user_id.should == @user.id
      DoneIdea.first.user.should == @user
    end
    
    it "should destroy associated done ideas" do
      @done_idea = @user.done_ideas.create({:idea => @idea})
      create_community_user
      @user.destroy
      DoneIdea.find_by_id(@done_idea.id).should be_nil
    end
    
    it "should have a marked_as_done? method" do
      @user.should respond_to(:marked_as_done?)
    end

    it "should have a mark_as_done! method" do
      @user.should respond_to(:mark_as_done!)
    end

    it "should have a unmark_as_done! method" do
      @user.should respond_to(:unmark_as_done!)
    end

    it "should mark an idea as done" do
      @user.mark_as_done!(@idea)
      @user.should be_marked_as_done(@idea)
    end

    it "should include the idea marked as done in the ideas marked as done array" do
      @user.mark_as_done!(@idea)
      @user.ideas_marked_as_done.should include(@idea)
    end

    it "should unmark an idea as done" do
      @user.mark_as_done!(@idea)
      @user.unmark_as_done!(@idea)
      @user.should_not be_marked_as_done(@idea)
    end
  end
  
   
  describe ":ideas_marked_as_done association" do
    before(:each) do
      @user = User.create(@attr)
      @idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)   
      @other_idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)         
      Factory(:done_idea, :user => @user, :idea => @idea)
      Factory(:done_idea, :user => @user, :idea => @other_idea)
    end
    
    it "should have a ideas_marked_as_done attribute" do
      @user.should respond_to(:ideas_marked_as_done)
    end
    
    it "should have two associated users" do
      @user.ideas_marked_as_done.all.size.should == 2
    end
  end

  describe "relationships" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
  
  describe "states" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an activation code" do
      @user.activation_code.should_not be_empty      
    end
    
    it "should not be activated" do
      @user.activated?.should == false
    end

    it "should be created in the pending state" do
      @user.state.should == "pending"
    end

    it "should switch to active state and be activated" do
      @user.activate!
      @user.state.should == "active"
      @user.activated?.should == true
    end
    
    it "should not change password" do
      @user.activate!
      @user.password.should_not be_blank
    end
  end
  
  describe "reset password" do
    
    before(:each) do
      @user = Factory(:activated_user)
    end
    
    it "should have a reset password method" do
      @user.should respond_to(:reset_password)
    end
    
    it "should generate a password reset code" do
      @user.reset_password
      @user.password_reset_code.should_not be_nil
    end
    
    it "should change the previous password reset code" do
      @user.reset_password
      last_reset_password = @user.password_reset_code
      @user.reset_password
      last_reset_password.should_not == @user.password_reset_code
    end
    
    it "should change the previous reset password mail sent at" do
      @user.reset_password
      last_reset_password_mail_sent_at = @user.reset_password_mail_sent_at
      @user.reset_password
      last_reset_password_mail_sent_at.should_not == @user.reset_password_mail_sent_at
    end
  end
  
  describe "reset_password_expired?" do
    
    before(:each) do
      @user = Factory(:activated_user)
    end
    
    it "should be expired if the reset password mail was sent two days ago" do
      @user.reset_password_mail_sent_at = 2.days.ago
      @user.reset_password_expired?.should == true
    end
    
    it "should not be expired if the reset password mail was sent two hours ago" do
      @user.reset_password_mail_sent_at = 2.hours.ago
      @user.reset_password_expired?.should == false
    end
  end
  
  describe "profile association" do
    
    it "should have a profile attribute" do
      user = Factory(:activated_user)
      user.should respond_to(:profile)
    end
  end
  
  describe "display name" do
    before(:each) do
      @profile = Factory(:profile)
      @user = @profile.user
    end
    
    it "should return the profile name" do
      @user.display_name.should == @profile.name
    end
    
    it "should return the user name if no user profile name" do
      @user.profile.name = ""
      @user.display_name.should == @user.name
    end
    
    it "should return the user name if no profile" do
      user = Factory(:activated_user)
      user.display_name.should == user.name
    end
  end
  
  describe "reminders_for_logged_user" do
    before(:each) do
      @user = Factory(:activated_user)
    end
    
    it "should have a reminders_for_logged_user method" do
      @user.should respond_to(:reminders_for_logged_user)
    end
    
    describe "cases" do
      before(:each) do
        @privacy = Factory(:privacy)
        @private_privacy = Factory(:privacy, :name => "private")
        @idea1 = Factory(:idea, :user => @user, :content => "Foo bar")
        @idea2 = Factory(:idea, :user => @user, :content => "Baz quux")
        @public_reminder = Factory(:reminder, :user => @user, :idea => @idea1, :created_at => 1.day.ago, :privacy => @privacy)
        @private_reminder = Factory(:reminder, :user => @user, :idea => @idea2, :created_at => 2.day.ago, :privacy => @private_privacy) 
      end
      
      it "should return both private and public posts if the logged user is the same as the user we request" do
        @user.reminders_for_logged_user(@user).should == [@public_reminder, @private_reminder]
      end
      
      it "should return public posts if the logged user is not the same as the user we request" do
        other_logged_user = Factory(:user, :email => Factory.next(:email))
        @user.reminders_for_logged_user(other_logged_user).should == [@public_reminder]
      end
      
      it "should return public posts if not logged user is not the same as the user we request" do
        @user.reminders_for_logged_user(nil).should == [@public_reminder]
      end
      
    end
  end
  
  describe "block user" do
    before(:each) do
      @user = User.create(@attr)
    end
    
    it "should be in the blocked state" do
      @user.block!
      @user.state.should == "blocked"
    end
    
  end
  
  describe "destroy" do
    
    before(:each) do
      @community_user = Factory(:community_user)
      @user = User.create(@attr)
      @public_privacy = Factory(:privacy)
      @private_privacy = Factory(:privacy, :name => "private") 
    end
    
    it "should destroy associated private ideas" do
      idea1 = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      idea2 = Factory(:idea, :user => @user, :created_at => 1.hour.ago)
      Factory(:reminder, :user => @user, :idea => idea1, :created_at => 2.day.ago, :privacy => @private_privacy)
      Factory(:reminder, :user => @user, :idea => idea2, :created_at => 2.day.ago, :privacy => @private_privacy)
      @user.destroy
      [idea1, idea2].each do |idea|
        Idea.find_by_id(idea.id).should be_nil
      end
      #lambda do
      #   Idea.find(idea.id)
      #end.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should destroy associated public ideas that were not shared with others" do
      idea1 = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      idea2 = Factory(:idea, :user => @user, :created_at => 1.hour.ago)
      Factory(:reminder, :user => @user, :idea => idea1, :created_at => 2.day.ago, :privacy => @public_privacy)
      Factory(:reminder, :user => @user, :idea => idea2, :created_at => 2.day.ago, :privacy => @public_privacy)
      @user.destroy
      [idea1, idea2].each do |idea|
        Idea.find_by_id(idea.id).should be_nil
      end
    end

    it "should not destory associated public ideas that were shared with others" do
      other_user = Factory(:user, :email => "other.user@yahoo.com")
      idea1 = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      idea2 = Factory(:idea, :user => @user, :created_at => 1.hour.ago)
      Factory(:reminder, :user => @user, :idea => idea1, :created_at => 2.day.ago, :privacy => @public_privacy)
      Factory(:reminder, :user => @user, :idea => idea2, :created_at => 2.day.ago, :privacy => @public_privacy)
      Factory(:reminder, :user => other_user, :idea => idea1, :created_at => 2.day.ago, :privacy => @public_privacy)
      @user.destroy
      Idea.find_by_id(idea1.id).should_not be_nil
      Idea.find_by_id(idea2.id).should be_nil
    end
    
    it "should donate to the community the assiciated public ideas that were shared with others" do
      other_user = Factory(:user, :email => "other.user@yahoo.com")
      idea1 = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      idea2 = Factory(:idea, :user => @user, :created_at => 1.hour.ago)
      Factory(:reminder, :user => @user, :idea => idea1, :created_at => 2.day.ago, :privacy => @public_privacy)
      Factory(:reminder, :user => @user, :idea => idea2, :created_at => 2.day.ago, :privacy => @public_privacy)
      Factory(:reminder, :user => other_user, :idea => idea1, :created_at => 2.day.ago, :privacy => @public_privacy)
      @user.destroy
      Idea.owned_by(@community_user).size.should == 1
    end

    it "should destroy associated idea_lists" do
      idea_list1 = Factory(:idea_list, :user => @user)
      idea_list2 = Factory(:idea_list, :user => @user, :name => "name 1")
      @user.destroy
      [idea_list1, idea_list2].each do |idea_list|
        IdeaList.find_by_id(idea_list.id).should be_nil
      end
    end
    
    it "should destroy associated reminders" do
      idea = Factory(:idea, :user => @user, :created_at => 1.day.ago)
      reminder1 = Factory(:reminder, :user => @user, :idea => idea, :privacy => @public_privacy, :created_at => 1.day.ago)
      reminder2 = Factory(:reminder, :user => @user, :idea => idea, :privacy => @public_privacy, :created_at => 1.hour.ago)
      @user.destroy
      Reminder.find_by_id(reminder1.id).should be_nil
      Reminder.find_by_id(reminder2.id).should be_nil
    end
    
    it "should destroy associated profile" do
      user = Factory(:activated_user)
      profile = Factory(:profile, :user => user)
      user.destroy
      Profile.find_by_id(profile.id).should be_nil
    end
  end
end
