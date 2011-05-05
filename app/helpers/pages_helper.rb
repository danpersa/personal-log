module PagesHelper

  def count_public_reminders_for_idea_group_by_user(idea)
    # first size returns the hash that conains the user and the reminders associated with it,
    # the second size returns the number of distinct users that shared this idea
    return Reminder.public_or_users_reminders_for_idea_group_by_user(idea, current_user).size.size
  end
  
end
