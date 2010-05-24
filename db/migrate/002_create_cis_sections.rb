class CreateCisSections < ActiveRecord::Migration
  def self.up
    create_table :cis_sections do |t|
      t.column "cis_semester_id", :integer,                               :null => false
      t.column "crn",             :integer
      t.column "stype",           :string,  :limit => 15, :default => "", :null => false
      t.column "name",            :string,                :default => "", :null => false
      t.column "startTime",       :time
      t.column "endTime",         :time
      t.column "days",            :string,  :limit => 13, :default => "", :null => false
      t.column "room",            :string,                :default => "", :null => false
      t.column "building",        :string,                :default => "", :null => false
      t.column "instructor",      :string,                :default => "", :null => false
    end
  end

  def self.down
    drop_table :cis_sections
  end
end
