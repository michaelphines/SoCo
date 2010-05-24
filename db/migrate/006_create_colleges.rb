class CreateColleges < ActiveRecord::Migration
  def self.up
    create_table :colleges do |t|
      t.column "code", :string, :limit => 2,  :default => "", :null => false
      t.column "name", :string, :limit => 45, :default => "", :null => false
    end

    restore_table_from_fixture "colleges"
  end

  def self.down
    drop_table :colleges
  end
end
