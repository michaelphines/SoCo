class CreateMajors < ActiveRecord::Migration
  def self.up
    create_table :majors do |t|
      t.column "name",       :string,                :default => "", :null => false
      t.column "college_id", :integer,                               :null => false
    end

    restore_table_from_fixture "majors"
  end

  def self.down
    drop_table :majors
  end
end
