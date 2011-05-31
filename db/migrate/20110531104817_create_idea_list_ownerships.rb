class CreateIdeaListOwnerships < ActiveRecord::Migration
  def self.up
    create_table :idea_list_ownerships do |t|
      t.integer :idea_list_id
      t.integer :idea_id
      t.timestamps
    end
    add_index :idea_list_ownerships, :idea_id
    add_index :idea_list_ownerships, :idea_list_id
  end

  def self.down
    remove_index :idea_list_ownerships, :idea_list_id
    remove_index :idea_list_ownerships, :idea_id
    drop_table :idea_list_ownerships
  end
end
