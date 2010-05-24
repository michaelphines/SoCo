require File.dirname(__FILE__) + '/../test_helper'

class CourseBinTest < Test::Unit::TestCase
  fixtures :course_bins

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_course_bin_create
    cb = CourseBin.new(:id=>3, :user_id=>0)
    assert_equal(true, cb.save())
    
    assert CourseBin.exists?(cb.id)
   
    cb.destroy
  end
  
  
  def test_course_bin_add_course
  
    #Create a new course bin
    cb = CourseBin.new(:id=>3, :user_id=>0)
          
    #Save it to the database
    cb.save
            
    #Get an object corresponding to the course with id 1
    #This course is created in the test fixtures
    course = CisCourse.find(1)
    course2 = CisCourse.find(3)
           
    #Add that course to the course bin
    cb.cis_courses.concat(course)
            
    #Make sure that the course now exists in the course bin
    assert cb.cis_courses.exists?(course.id)
    assert !cb.cis_courses.exists?(course2.id)
    cb.destroy 
  end
  
  def test_course_bin_remove_course
    cb = CourseBin.new(:id=>3, :user_id=>0)
    cb.save
    
    course = CisCourse.find(1)
    course1 = CisCourse.find(3)
    
    cb.cis_courses.concat(course)
    cb.cis_courses.concat(course1)
    
    assert cb.cis_courses.exists?(course.id)
    assert cb.cis_courses.exists?(course1.id)
    
    cb.cis_courses.delete(course)
    
    assert !cb.cis_courses.exists?(course.id)
    assert cb.cis_courses.exists?(course1.id)
    
    assert_equal(1, cb.cis_courses.count)
    
    cb.destroy
  end
  
end
