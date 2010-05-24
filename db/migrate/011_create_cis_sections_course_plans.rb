class CreateCisSectionsCoursePlans < ActiveRecord::Migration
  def self.up
    create_table :cis_sections_course_plans, :id => false do |t|
      t.column "cis_section_id", :integer, :null => false
      t.column "course_plan_id",  :integer, :null => false
    end
  end

  def self.down
    drop_table :cis_sections_course_plans
  end
end
