class CreateCourseDependencies < ActiveRecord::Migration
  def self.up
    create_table :course_dependencies do |t|
      t.column "node_type", :enum, :limit => [:COURSE, :CONCURRENT, :OR], :null => false
    end
  end

  def self.down
    drop_table :course_dependencies
  end
end
