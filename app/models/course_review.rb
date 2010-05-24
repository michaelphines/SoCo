class CourseReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :cis_course
  
  validates_presence_of :title, :body
end
