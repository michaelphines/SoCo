class Major < ActiveRecord::Base
  has_many :users
  belongs_to :college
end
