require File.dirname(__FILE__) + '/../test_helper'

class CourseDependencyTest < Test::Unit::TestCase
  fixtures :course_dependencies, :course_dependency_edges, :semesters, :users, :cis_courses, :cis_courses_semesters

  def test_course_is_in_earlier_semester
    ben = users(:ben)
    cs225 = cis_courses(:cs225)
    cs473 = cis_courses(:cs473)
    cs428 = cis_courses(:cs428)
    math412 = cis_courses(:math412)
      
    assert cs473.course_dependency.course_is_in_earlier_semester?(9, ben)
    assert !cs428.course_dependency.course_is_in_earlier_semester?(9, ben)
    assert !cs225.course_dependency.course_is_in_earlier_semester?(9, ben)
    assert cs225.course_dependency.course_is_in_earlier_semester?(10, ben)

    #check some of the boundary conditions    
    assert !cs473.course_dependency.course_is_in_earlier_semester?(semesters(:ben1).id, ben)
    assert cs473.course_dependency.course_is_in_earlier_semester?(semesters(:ben8).id, ben)
    assert !math412.course_dependency.course_is_in_earlier_semester?(semesters(:ben8).id, ben)  
  end
  

  def test_is_satisfied
    ben = users(:ben)
    cs225 = cis_courses(:cs225)
    psych100 = cis_courses(:phych100)
    cs473 = cis_courses(:cs473)
    math412 = cis_courses(:math412)
    
    # Test COURSE nodes
    assert cs225.course_dependency.is_satisfied?(semesters(:ben4).id, ben)
    assert !cs225.course_dependency.is_satisfied?(semesters(:ben1).id, ben)
    assert !cs225.course_dependency.is_satisfied?(semesters(:ben2).id, ben)
    assert !cs225.course_dependency.is_satisfied?(semesters(:ben3).id, ben)
    assert cs225.course_dependency.is_satisfied?(semesters(:ben8).id, ben)    
    
    # Test OR nodes
    assert !psych100.course_dependency.is_satisfied?(semesters(:ben1).id, ben)
    assert !psych100.course_dependency.is_satisfied?(semesters(:ben2).id, ben)
    assert !psych100.course_dependency.is_satisfied?(semesters(:ben3).id, ben)    
    assert psych100.course_dependency.is_satisfied?(semesters(:ben4).id, ben)
    assert psych100.course_dependency.is_satisfied?(semesters(:ben5).id, ben)
    assert psych100.course_dependency.is_satisfied?(semesters(:ben6).id, ben)    
    assert psych100.course_dependency.is_satisfied?(semesters(:ben7).id, ben)
    assert psych100.course_dependency.is_satisfied?(semesters(:ben8).id, ben)


    # Test AND node
    assert !cs473.course_dependency.is_satisfied?(semesters(:ben1).id, ben)
    assert !cs473.course_dependency.is_satisfied?(semesters(:ben2).id, ben)
    assert !cs473.course_dependency.is_satisfied?(semesters(:ben3).id, ben)    
    assert !cs473.course_dependency.is_satisfied?(semesters(:ben4).id, ben)
    assert !cs473.course_dependency.is_satisfied?(semesters(:ben5).id, ben)
    assert cs473.course_dependency.is_satisfied?(semesters(:ben6).id, ben)    
    assert cs473.course_dependency.is_satisfied?(semesters(:ben7).id, ben)
    assert cs473.course_dependency.is_satisfied?(semesters(:ben8).id, ben)    
    
    # Test CONCURRENT node
    assert !math412.course_dependency.is_satisfied?(semesters(:ben1).id, ben)
    assert !math412.course_dependency.is_satisfied?(semesters(:ben2).id, ben)
    assert !math412.course_dependency.is_satisfied?(semesters(:ben3).id, ben)    
    assert math412.course_dependency.is_satisfied?(semesters(:ben4).id, ben)
    assert math412.course_dependency.is_satisfied?(semesters(:ben5).id, ben)
    assert math412.course_dependency.is_satisfied?(semesters(:ben6).id, ben)    
    assert math412.course_dependency.is_satisfied?(semesters(:ben7).id, ben)
    assert math412.course_dependency.is_satisfied?(semesters(:ben8).id, ben)    
    
  end  
  
end
