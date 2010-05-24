require File.dirname(__FILE__) + '/../test_helper'

class SemesterTest < Test::Unit::TestCase
  fixtures :semesters
  
 def test_create_semesters
    #Create a new user with the specified attributes
    kathleen = 
                 User.new(:username=>'kathleen', 
                 :password=>"koala1",
                 :first_name=>'Kathleen',
                 :last_name=>'Reilly', 
                 :email=>'kereilly@uiuc.edu',
                 :start_year=>'2003',
                 :start_sem=>'FA', 
                 :birthday=>'1984-12-09', 
                 :college => College.find(:first),
                 :major => Major.find(:first)
                 )  
    assert kathleen.save
    
    
    #Check to make sure the proper semesters exist
    assert !Semester.exists?(:year=>'2003', :semester=>'SP', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2003', :semester=>'FA', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2004', :semester=>'SP', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2004', :semester=>'FA', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2005', :semester=>'SP', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2005', :semester=>'FA', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2006', :semester=>'SP', :user_id=>kathleen.id)
    assert Semester.exists?(:year=>'2006', :semester=>'FA', :user_id=>kathleen.id)       
    assert Semester.exists?(:year=>'2007', :semester=>'SP', :user_id=>kathleen.id)         
    assert !Semester.exists?(:year=>'2007', :semester=>'FA', :user_id=>kathleen.id)         
    
    kathleen.destroy

 end
  
end
