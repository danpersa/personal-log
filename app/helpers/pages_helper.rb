module PagesHelper

  def count_public_reminders_for_idea(idea)
    return Reminder.public_or_users_reminders_for_idea(idea, current_user).size
  end
  
end
