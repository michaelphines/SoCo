class ChangePasswordHashType < ActiveRecord::Migration
  #FIX for MySQL until
  #http://dev.rubyonrails.org/ticket/6695
  #is merged into rails
  def self.up
    change_column :users, :password_hash, :string, :length => 40
  end

  def self.down
    change_column :users, :password_hash, :blob, :length => 40
  end
end
