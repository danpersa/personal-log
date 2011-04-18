class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :name
      t.string :email
      t.string :website
      t.string :location
      t.integer :user_id
      t.timestamps
    end
    add_index :profiles, :user_id
  end

  def self.down
    remove_index :profiles, :user_id
    drop_table :profiles
  end
end
