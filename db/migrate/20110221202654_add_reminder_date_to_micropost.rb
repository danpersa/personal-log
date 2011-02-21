class AddReminderDateToMicropost < ActiveRecord::Migration
  def self.up
    add_column :microposts, :reminder_date, :date
  end

  def self.down
    remove_column :microposts, :reminder_date
  end
end
