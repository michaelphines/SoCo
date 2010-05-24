class CreateCisCourses < ActiveRecord::Migration
  def self.up
    create_table :cis_courses do |t|
      t.column "cis_subject_id", :integer,                               :null => false
      t.column "number",         :integer, :limit => 3,                  :null => false
      t.column "title",          :string,  :limit => 30, :default => "", :null => false
    end
  end

  def self.down
    drop_table :cis_courses
  end
end
