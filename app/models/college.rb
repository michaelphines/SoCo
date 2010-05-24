class College < ActiveRecord::Base
  has_many :majors
  has_many :users
end
