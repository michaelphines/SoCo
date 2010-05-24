require File.dirname(__FILE__) + '/../test_helper'

class CisSubjectTest < Test::Unit::TestCase
  fixtures :cis_subjects

   
  # Test if object of type CisSubject is created automatically
  def test_create_CisSubject_object
  
    zulu = CisSubject.new(:id=>3, :code=>'ZULU')
    assert zulu.save  
    zulu.destroy
  end
  
  # Test if search function is functioning correctly
  def test_unsuccessful_search_for_courses
      assert CisSubject.search_for_course('TEMPE').empty?
      assert CisSubject.search_for_course('P9OP').empty? 
      assert CisSubject.search_for_course('CS2255').empty?     
  end
  
  #Test the successful search returns
  def test_successful_search_for_courses
      assert_equal(1, CisSubject.search_for_course('CS22').size())
      assert_equal(1, CisSubject.search_for_course('math ').size())
      assert_equal(1, CisSubject.search_for_course('CS').size())

  end
                
end
