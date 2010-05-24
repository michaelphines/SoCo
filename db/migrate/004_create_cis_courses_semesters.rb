class CreateCisCoursesSemesters < ActiveRecord::Migration
  def self.up
    create_table :cis_courses_semesters, :id => false do |t|
      t.column "cis_course_id", :integer, :null => false
      t.column "semester_id",  :integer, :null => false
    end
  end

  def self.down
    drop_table :cis_courses_semesters
  end
end
