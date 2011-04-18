class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.integer :user_id
      t.integer :idea_id
      t.date :reminder_date
      t.integer :privacy_id
      t.timestamps
    end
    
    add_index :reminders, :user_id
    add_index :reminders, :idea_id
  end

  def self.down
    drop_table :reminders
  end
end
