class ModifyCourseDependenciesNodeType < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE course_dependencies CHANGE node_type node_type enum('COURSE','CONCURRENT','OR','AND') NOT NULL"
  end

  def self.down
    execute "ALTER TABLE course_dependencies CHANGE node_type node_type enum('COURSE','CONCURRENT','OR') NOT NULL"
  end
end
