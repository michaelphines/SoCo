class CreateCisSemesters < ActiveRecord::Migration
  def self.up
    create_table :cis_semesters do |t|
      t.column "cis_course_id", :integer,                            :null => false
      t.column "year",          :integer, :limit => 4,               :null => false
      t.column "semester",      :enum,    :limit => [:SP, :SU, :FA], :null => false
    end
  end

  def self.down
    drop_table :cis_semesters
  end
end
