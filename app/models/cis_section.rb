class CisSection < ActiveRecord::Base
  belongs_to :cis_semester
  has_and_belongs_to_many :course_plans
end
