class CreateGoodIdeas < ActiveRecord::Migration
  def self.up
    create_table :good_ideas do |t|
      t.integer :user_id
      t.integer :idea_id
      t.timestamps
    end
    
    add_index :good_ideas, :idea_id
  end

  def self.down
    remove_index :good_ideas, :idea_id
    drop_table :good_ideas
  end
end
