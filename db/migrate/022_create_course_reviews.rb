class CreateCourseReviews < ActiveRecord::Migration
  def self.up
    create_table :course_reviews do |t|
      t.column :user_id, :integer
      t.column :cis_course_id, :integer
      t.column :title, :string
      t.column :created_at, :datetime
      t.column :body, :text
    end
  end

  def self.down
    drop_table :course_reviews
  end
end
