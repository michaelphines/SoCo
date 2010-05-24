class Semester < ActiveRecord::Base
  has_and_belongs_to_many :cis_courses
  has_one :course_plan, :dependent => :destroy
  belongs_to :user

  after_create :create_dependancies
  
  #SEMESTER YEAR
  def to_s
    return semester.to_s + " " + year.to_s
  end
  
  #creates +num_of_semesters+ consecutive semesters from +start_semester+ and +start_year+
  #yields a new semester object
  def self.create_semesters(start_semester, start_year, num_of_semesters)
    i_year = start_year
    i_semester = start_semester
  
    for i in 1..num_of_semesters
      yield Semester.new(:year => i_year, :semester => i_semester)  

      i_semester, i_year = get_next_semester_and_year(i_semester, i_year)
    end
  end
  
  #returns the next consecutive semester and year
  def self.get_next_semester_and_year(i_semester, i_year)
    if i_semester.to_s == 'SP'
      i_semester = 'FA'
    else
      i_semester = 'SP'
      i_year += 1
    end
    
    return i_semester, i_year
  end
  
  #returns the next consecutive semester and year
  #same as above, except instance method
  def get_next_semester_and_year
    return Semester.get_next_semester_and_year(semester, year)
  end
  
  private
  #create course plan upon creation of this object
  def create_dependancies
    create_course_plan()
  end
  
end
