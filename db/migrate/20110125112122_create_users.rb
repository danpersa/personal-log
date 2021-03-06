class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
    add_index :users, :email, :unique => true
  end

  def self.down
    remove_index :users, :email
    drop_table :users
  end
end
