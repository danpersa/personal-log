class CreatePrivacies < ActiveRecord::Migration
  def self.up
    create_table :privacies do |t|
      t.string :name

      t.timestamps
    end
    
    add_index :privacies, :name, :unique => true
  end

  def self.down
    remove_index :privacies, :name
    drop_table :privacies
  end
end
