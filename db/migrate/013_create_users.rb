class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "username",      :string,                                             :null => false
      t.column "password_hash", :binary,                                             :null => false
      t.column "first_name",    :string,                             :default => "", :null => false
      t.column "last_name",     :string,                             :default => "", :null => false
      t.column "email",         :string,                                             :null => false
      t.column "start_year",    :integer, :limit => 4,                               :null => false
      t.column "start_sem",     :enum,    :limit => [:SP, :SU, :FA],                 :null => false
      t.column "birthday",      :date,                                               :null => false
      t.column "college_id",    :integer,                                            :null => false
      t.column "major_id",      :integer,                                            :null => false
    end

    add_index :users, ["username"], :name => "username", :unique => true
  end

  def self.down
    drop_table :users
  end
end
