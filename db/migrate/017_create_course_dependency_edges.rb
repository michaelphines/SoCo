class CreateCourseDependencyEdges < ActiveRecord::Migration
  def self.up
    create_table :course_dependency_edges, :id => false do |t|
      t.column "parent_id", :integer, :null => false
      t.column "child_id",  :integer, :null => false
    end
  end

  def self.down
    drop_table :course_dependency_edges
  end
end
