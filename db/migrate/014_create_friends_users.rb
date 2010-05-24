class CreateFriendsUsers < ActiveRecord::Migration
  def self.up
    create_table :friends_users, :id => false do |t|
      t.column "friend_id", :integer, :null => false
      t.column "user_id",   :integer, :null => false
    end
  end

  def self.down
    drop_table :friends_users
  end
end
