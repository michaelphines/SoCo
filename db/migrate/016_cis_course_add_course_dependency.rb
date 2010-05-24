class CisCourseAddCourseDependency < ActiveRecord::Migration
  def self.up
    add_column :cis_courses, :course_dependency_id, :integer
    add_column :cis_courses, :description, :text
  end

  def self.down
    remove_column :cis_courses, :course_dependency_id
    remove_column :cis_courses, :description
  end
end
