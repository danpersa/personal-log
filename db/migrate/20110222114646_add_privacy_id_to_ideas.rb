class AddPrivacyIdToIdeas < ActiveRecord::Migration
  def self.up
    add_column :ideas, :privacy_id, :integer
  end

  def self.down
    remove_column :ideas, :privacy_id
  end
end
