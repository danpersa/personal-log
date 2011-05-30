class CreateIdeaLists < ActiveRecord::Migration
  def self.up
    create_table :idea_lists do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
    
    add_index :idea_lists, :user_id
    add_index :idea_lists, :name
  end

  def self.down
    remove_index :idea_lists, :user_id
    remove_index :idea_lists, :name
    drop_table :idea_lists
  end
end
