class AddReminderDateToIdeas < ActiveRecord::Migration
  def self.up
    add_column :ideas, :reminder_date, :date
  end

  def self.down
    remove_column :ideas, :reminder_date
  end
end
