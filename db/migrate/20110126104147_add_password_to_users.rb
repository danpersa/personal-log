class AddPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :encrypted_password, :string
    add_index  :users, :encrypted_password
  end

  def self.down
    remove_index  :users, :encrypted_password
    remove_column :users, :encrypted_password
  end
end
