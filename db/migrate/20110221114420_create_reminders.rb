class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.date :reminder_date
      t.timestamps
    end
    add_index :reminders, :reminder_date
  end

  def self.down
    drop_table :reminders
  end
end
