class AddStateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :state, :string, :null => :no, :default => 'pending'
  end

  def self.down
    remove_column :users, :state
  end
end
