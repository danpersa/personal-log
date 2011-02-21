class AddMicropostToReminders < ActiveRecord::Migration
  def self.up
    add_column :reminders, :micropost_id, :integer
    add_index :reminders, :micropost_id
  end

  def self.down
    remove_column :reminders, :micropost_id
  end
end
