class CreatePrivacies < ActiveRecord::Migration
  def self.up
    create_table :privacies do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :privacies
  end
end
