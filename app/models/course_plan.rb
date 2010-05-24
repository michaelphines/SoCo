class CoursePlan < ActiveRecord::Base
  belongs_to :semester
  has_and_belongs_to_many :cis_sections
end
