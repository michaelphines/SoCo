class CreateCisCoursesCourseBins < ActiveRecord::Migration
  def self.up
    create_table :cis_courses_course_bins, :id => false do |t|
      t.column "cis_course_id", :integer, :null => false
      t.column "course_bin_id",  :integer, :null => false
    end
  end

  def self.down
    drop_table :cis_courses_course_bins
  end
end
