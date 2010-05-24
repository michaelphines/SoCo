class CisCourse < ActiveRecord::Base
  has_many :cis_semesters
  belongs_to :cis_subject
  belongs_to :course_dependency
  has_and_belongs_to_many :course_bins
  has_and_belongs_to_many :semesters
  has_many :shared_courses
  has_many :course_reviews
  
  #iterator over all friends sharing this course for this user
  #yields shared course id, friend, and friend's semester
  def iterate_users_semesters(user)
    #find all relationship objects for this user id AND cis_course
    
    shared_course_list = shared_courses.find :all, :include => 'relationship', :conditions => ["relationships.user_id = ?", user.id]
    
    shared_course_list.each do |shared|
      friend = shared.relationship.friend
      
      #fix for relationship which didn't get deleted properly
      if not friend.nil?
        semester = Semester.find_by_sql ["SELECT semesters.* FROM semesters LEFT OUTER JOIN cis_courses_semesters ON cis_courses_semesters.semester_id = semesters.id WHERE semesters.user_id = ? AND cis_courses_semesters.cis_course_id = ? LIMIT 1", friend.id, id]
      
        yield shared.id, friend, semester
      end
    end
  end
  
  #to a string
  #SUBJECT ###
  def to_s
    return cis_subject.to_s + ' ' + number.to_s
  end
  
  #checks to make sure the course dependencies are satisfied for taking this course
  #in +semester_id+ semester on +user_id+'s schedule
  def dependencies_satisfied?(semester_id, user_id)
    if semester_id == -1
      return true
    end
    
    user = User.find(user_id)
   
    return course_dependency.is_satisfied?(semester_id, user)
  end
  
  #gets a list of sections for this course during the specified +semester+
  def sections_for_semester semester
    semesters = cis_semesters.find(:first, :conditions => {:semester => semester.semester, :year => semester.year})
    return (semesters and semesters.cis_sections)
  end
end
