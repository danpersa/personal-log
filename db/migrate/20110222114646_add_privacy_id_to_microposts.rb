class AddPrivacyIdToMicroposts < ActiveRecord::Migration
  def self.up
    add_column :microposts, :privacy_id, :integer
  end

  def self.down
    remove_column :microposts, :privacy_id
  end
end
