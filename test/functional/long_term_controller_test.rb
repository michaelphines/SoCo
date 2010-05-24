require File.dirname(__FILE__) + '/../test_helper'
require 'long_term_controller'

# Re-raise errors caught by the controller.
class LongTermController; def rescue_action(e) raise e end; end

class LongTermControllerTest < Test::Unit::TestCase

  fixtures :users, :semesters, :cis_courses, :course_bins, :cis_subjects, :course_dependencies , :relationships, :cis_courses_semesters

  
  def setup
    @controller = LongTermController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = 1
  end

 def test_index
   get :index
   assert_response :success
 end
 
 def test_show  
  get :show, :id => @request.session[:user]
  assert_response :success
  assert_template 'show'
  assert_not_nil assigns(:user)  
 end
 

 def test_add_class
   user = User.find(@request.session[:user]) 
   count = user.course_bin.cis_courses.count   
   
   post :add_class,  :course=>{:number=>"CS225"}
   assert_response  :success
   assert_template  "add_class"                             
   assert_equal count+1, user.course_bin.cis_courses.count
   
 end
 
 #see issue 67#
 def test_add_class_for_invalid_course_name
   user = User.find(@request.session[:user]) 
   count = user.course_bin.cis_courses.count   
   
   post :add_class,  :course=>{:number=>"Accy"}
   assert_response  :success 
   assert_template  "ajax_flash" 
   assert_equal count, user.course_bin.cis_courses.count
   
 end
 
 
 def test_remove_class_from_course_bin
 
  user = User.find(@request.session[:user])
  
  post :add_class, :course=>{:number=>"CS225"}
  post :add_class, :course=>{:number=>"CS473"}
  
  assert_equal 2, user.course_bin.cis_courses.count
  
  post :remove, :course_id=> cis_courses('cs225').id, :semester_id => -1
  
  assert_equal 1, user.course_bin.cis_courses.count

 end
 
 def test_remove_class_from_schedule
 user = User.find(@request.session[:user])
 
 post :add_class, :course=>{:number=>"CS225"}
 assert_equal 1, user.course_bin.cis_courses.count
 
 post :update_semester, {:id=> 'coursediv_-1_1', :new_semester=>1}
 assert_response :success
 assert_equal 0, user.course_bin.cis_courses.count

 post :remove, :course_id=> cis_courses('cs225').id, :semester_id=> 1
 assert_response  :success
 assert_template  "remove"                             
 end
 
 def test_update_semester
  user = User.find(@request.session[:user])
  
  post :add_class, :course=>{:number=>"CS225"}
  post :add_class, :course=>{:number=>"CS473"}
  
  assert_equal 2, user.course_bin.cis_courses.count
  
  post :update_semester, {:id=>'coursediv_-1_3', :new_semester=>1}
  assert_response :success
  
  post :update_semester, {:id=>'coursediv_-1_1', :new_semester=>1}
  assert_response :success
  
  assert_equal 0, user.course_bin.cis_courses.count

 end
 
 def test_course_name_gt_6_chars
    post :add_class, :course=>{:number=>"ABCDEFG225"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_redirected_to :action => 'index'   
   #assert_equal false, flash.empty?
   #assert_equal "Invalid Course" ,flash[:error]            
 end

 #add the course if it exists in DB
 def test_course_name_lt_6_chars
     user = User.find(@request.session[:user]) 
     count = user.course_bin.cis_courses.count   
 
 
    post :add_class, :course=>{:number=>"PSYCH100"}
    assert_response :success
    assert_template "add_class"

   #assert_response :redirect
   #assert_redirected_to :action => 'index'  
   #assert flash.empty?       
        
    assert_equal count+1, user.course_bin.cis_courses.count            
 end
 
 def test_course_number_gt_3_digits
    post :add_class, :course=>{:number=>"CS2255"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'      
   #assert_equal "Invalid Course" ,flash[:error]            
 end
    
 #adds the first course in the auto complete      
 def test_course_number_lt_3_digits
     user = User.find(@request.session[:user]) 
     count = user.course_bin.cis_courses.count   
   
 
    post :add_class, :course=>{:number=>"CS22"}
    assert_response :success
    assert_template "add_class"
    
   #assert_response :redirect
   #assert_redirected_to :action => 'index'  
   #assert flash.empty?       
        
    assert_equal count+1, user.course_bin.cis_courses.count        
            
 end    
 
 def test_nil_case
    post :add_class, :course=>{:number=>""}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'      
   #assert_equal "Invalid Course" ,flash[:error]            
 end
 
 def test_invalid_chars
    post :add_class, :course =>{:number=> "CS42*"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'
   #assert_equal "Invalid Course", flash[:error]
    
    post :add_class, :course =>{:number => "ECE&^%"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'
   #assert_equal "Invalid Course", flash[:error]
    
    post :add_class, :course =>{:number => "C*&^%"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'
   #assert_equal "Invalid Course", flash[:error]
 end
 
 def test_invalid_courses_correct_length
    post :add_class, :course =>{:number => "ECE900"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'
   #assert_equal "Invalid Course", flash[:error]
    
    post :add_class, :course =>{:number => "ECE429"}
    assert_response :success
    assert_template "ajax_flash"
   #assert_response :redirect
   #assert_redirected_to :action => 'index'
   #assert_equal "Invalid Course", flash[:error]
 end
 
 #assume that the course existe in user's four year plan
 def test_take_course_with_friend     
   #this course is added in to user's course bin
   user = User.find(@request.session[:user]) 
   count = user.course_bin.cis_courses.count         
   post :add_class,  :course=>{:number=>"CS411"}        
   assert_response :success
    assert_template "add_class"
  #assert_response :redirect
  #assert_redirected_to :action => 'index'  
  #assert flash.empty?              
   assert_equal count+1, user.course_bin.cis_courses.count
   
   #now we will try to share the same course from friend's 4 year plan
   # NOTE: we need to set this because we are using redirect :back in this controller
   # we need to set
   @request.env['HTTP_REFERER'] = 'http://whatever'    
   post :take_course_with_friend, :friend_id=>4, :semester_id=>3, :course_id=>6
   assert_response :redirect
   assert_redirected_to 'http://whatever'
   
   #make sure the link is created 
   user_friend_relationship = Relationship.find_by_user_and_friend(1, 4)
   friend_user_relationship = Relationship.find_by_user_and_friend(4, 1)   
   assert user_friend_relationship.shared_courses.exists?(:cis_course_id => 6)
   assert friend_user_relationship.shared_courses.exists?(:cis_course_id => 6)              
 end
 
 #assume that the course does not existe in user's four year plan
 def test_take_course_with_friend_1
   
   #make sure the course does not exists in my schedule
   user = User.find(@request.session[:user])
   assert_equal false, user.has_course?(6)
   
   #take course with him
   @request.env['HTTP_REFERER'] = 'http://whatever'    
   post :take_course_with_friend, :friend_id=>4, :semester_id=>3, :course_id=>6
   assert_response :redirect
   assert_redirected_to 'http://whatever'
   
   #make sure the link is created 
   user_friend_relationship = Relationship.find_by_user_and_friend(1, 4)
   friend_user_relationship = Relationship.find_by_user_and_friend(4, 1)   
   assert user_friend_relationship.shared_courses.exists?(:cis_course_id => 6)
   assert friend_user_relationship.shared_courses.exists?(:cis_course_id => 6)        
   
   #check if that course exists in user's four year plan
   assert_equal true, user.has_course?(6)
 end
 
 # this is the case when user is calling this controller from its own long term view 
 def test_take_course_with_friend_2
   
   post :take_course_with_friend, :friend_id => 1, :semester_id=>3, :course_id=>6
   assert_response :success
   
 end
  
 def test_delete_shared_course
   
   #first add a link
   @request.env['HTTP_REFERER'] = 'http://whatever'    
   post :take_course_with_friend, :friend_id=>4, :semester_id=>3, :course_id=>6
   assert_response :redirect
   assert_redirected_to 'http://whatever'
   
   #get the shared id
   user_friend_relationship = Relationship.find_by_user_and_friend(1, 4)
   shared_id = user_friend_relationship.shared_courses.find(:first, :conditions=>{:cis_course_id => 6}).id
   
   #now delete the link 
   @request.env['HTTP_REFERER'] = 'http://whatever'    
   post :delete_shared_course, :id=>shared_id
   assert_response :redirect
   assert_redirected_to 'http://whatever'
   
   #check if it exists?
   assert_equal false,user_friend_relationship.shared_courses.exists?(:cis_course_id => 6)
   
 end
 
 #assume that friend already has the course in his 4 year plan
 def test_my_course_with_friend
 
   #this course is added in to user's course bin
   user = User.find(@request.session[:user]) 
   count = user.course_bin.cis_courses.count         
   post :add_class,  :course=>{:number=>"CS411"}        
   assert_response :success
   assert_template "add_class"
  #assert_response :redirect
  #assert_redirected_to :action => 'index'  
  #assert flash.empty?              
   assert_equal count+1, user.course_bin.cis_courses.count
       
   #ask him to take course with me

   post :take_my_course_with_friend, :friends=>[4], :course_id=>6
   assert_response :redirect
   assert_redirected_to :action => 'index'
   assert flash.empty?              
   
   #make sure the link is created 
   user_friend_relationship = Relationship.find_by_user_and_friend(1, 4)
   friend_user_relationship = Relationship.find_by_user_and_friend(4, 1)   
   assert user_friend_relationship.shared_courses.exists?(:cis_course_id => 6)
   assert friend_user_relationship.shared_courses.exists?(:cis_course_id => 6)  
 
 end
 
 #assume that friend does not have that course in his 4 year plan
 def test_my_course_with_friend_1
 
   #ask him to take course with me

   post :take_my_course_with_friend, :friends=>[4], :course_id=>5
   assert_response :redirect
   assert_redirected_to :action => 'index'
   assert flash.empty?              
   
   #make sure the link is created 
   user_friend_relationship = Relationship.find_by_user_and_friend(1, 4)
   friend_user_relationship = Relationship.find_by_user_and_friend(4, 1)   
   assert user_friend_relationship.shared_courses.exists?(:cis_course_id => 5)
   assert friend_user_relationship.shared_courses.exists?(:cis_course_id => 5)
   
   #check if the friend has it
   friend = User.find(4)
   assert_equal true, friend.has_course?(5)
 
end
 
#test with no friend selected
def test_my_course_with_friend_with_no_friend_selected
 
   #ask him to take course with me
   post :take_my_course_with_friend, :friends=>nil, :course_id=>5
   assert_response :redirect
   assert_redirected_to :action => 'index'
   assert_equal "You must select a friend to take this course with.", flash[:error]              
    
end

#test with multiple friends selected
def test_my_course_with_friend_with_multiple_friend_selected
  
  #ask him to take course with me
  post :take_my_course_with_friend, :friends=>[3,4], :course_id=>5
  assert_response :redirect
  assert_redirected_to :action => 'index'
  
  #make sure the link is created 
  user_friend1_relationship = Relationship.find_by_user_and_friend(1, 4)
  friend1_user_relationship = Relationship.find_by_user_and_friend(4, 1)   
  user_friend2_relationship = Relationship.find_by_user_and_friend(1, 3)
  friend2_user_relationship = Relationship.find_by_user_and_friend(3, 1)   
  
  assert user_friend1_relationship.shared_courses.exists?(:cis_course_id => 5)
  assert friend1_user_relationship.shared_courses.exists?(:cis_course_id => 5)
  assert user_friend2_relationship.shared_courses.exists?(:cis_course_id => 5)
  assert friend2_user_relationship.shared_courses.exists?(:cis_course_id => 5)
  
  #check if the friends have it
  friend1 = User.find(4)
  assert_equal true, friend1.has_course?(5)
  friend2 = User.find(3)
  assert_equal true, friend2.has_course?(5)
end

#test adding duplicate link
def add_duplicate_shared_course
  #ask him to take course with me
  post :take_my_course_with_friend, :friends=>[4], :course_id=>5
  assert_response :redirect
  assert_redirected_to :action => 'index'
  
  post :take_my_course_with_friend, :friends=>[4], :course_id=>5
  assert_response :redirect
  assert_redirected_to :action => 'index'
  assert_equal "You are already taking this course with your friend", flash[:error]
end

def test_push_semester

  before_semester_count = Semester.find(:all, :conditions=>{:user_id=>1}).size 
  post  :push_semester
  assert_response :redirect
  assert_redirected_to :action => 'index'
  after_semester_count = Semester.find(:all, :conditions=>{:user_id=>1}).size
  assert_equal before_semester_count+1, after_semester_count
  
end

def test_pop_semester

  before_semester_count = Semester.find(:all, :conditions=>{:user_id=>1}).size 
  post  :pop_semester
  assert_response :redirect
  assert_redirected_to :action => 'index'
  after_semester_count = Semester.find(:all, :conditions=>{:user_id=>1}).size
  assert_equal before_semester_count-1, after_semester_count

end

def test_auto_complete_for_course_number
  get :auto_complete_for_course_number, :course=>{:number=>"CS225"}
  assert_not_nil assigns(:courses)
  assert_response :success
end



end
