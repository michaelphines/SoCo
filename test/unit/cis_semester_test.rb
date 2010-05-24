require File.dirname(__FILE__) + '/../test_helper'

class CisSemesterTest < Test::Unit::TestCase
  fixtures :cis_semesters

  def test_semester_word
  
  spring = cis_semesters(:first)
  fall = cis_semesters(:another)  
  summer = cis_semesters(:third)  
  
  assert_equal("Spring", spring.semester_word)
  assert_equal("Fall", fall.semester_word)
  assert_equal("Summer", summer.semester_word)
  
  end

end
