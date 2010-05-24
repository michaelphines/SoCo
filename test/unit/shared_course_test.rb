require File.dirname(__FILE__) + '/../test_helper'

class SharedCourseTest < Test::Unit::TestCase
  fixtures :shared_courses


def test_get_friend
  #first save a shared course
  temp = SharedCourse.new(:cis_course_id=>3, :relationship_id=>5)
  assert_nothing_raised{ temp.save! }
  
  #now find a shared course
  get_shared_course = SharedCourse.find(:first, :conditions=>{:cis_course_id=>3, :relationship_id=>5})
  assert_equal get_shared_course.get_friend(User.find(1)).id, 4
  assert_equal get_shared_course.get_friend(User.find(4)).id, 1
  temp.destroy
  
end


end
