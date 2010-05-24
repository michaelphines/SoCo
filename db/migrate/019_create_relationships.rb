class CreateRelationships < ActiveRecord::Migration
  def self.up
    rename_table :friends_users, :relationships

    add_column :relationships, 'id', :primary_key
  end

  def self.down
    remove_column :relationships, 'id'

    rename_table :relationships, :friends_users
  end
end
