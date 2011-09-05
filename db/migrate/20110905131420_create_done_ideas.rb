class CreateDoneIdeas < ActiveRecord::Migration
  def self.up
    create_table :done_ideas do |t|
      t.integer :user_id
      t.integer :idea_id
      t.timestamps
    end
    add_index :done_ideas, :user_id
    add_index :done_ideas, :idea_id
  end

  def self.down
    remove_index :done_ideas, :idea_id
    remove_index :done_ideas, :user_id
    drop_table :done_ideas
  end
end
