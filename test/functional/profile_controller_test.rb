require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

# Re-raise errors caught by the controller.
class ProfileController; def rescue_action(e) raise e end; end

class ProfileControllerTest < Test::Unit::TestCase
  fixtures :users, :relationships, :colleges, :majors

  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = 1
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'show'
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
  end

  def test_register
    num_users = User.count

    post :register, :user => {  :username=>'nikhil', 
                                :password=>'sonie123',
                                :first_name=>'abcd',
                                :last_name=>'cdef', 
                                :email=>'nsonie2@uiuc.edu',
                                :start_year=>'2009',
                                :start_sem=>'FA', 
                                :birthday=>'1990-10-29', 
                                :college => College.find(:first),
                                :major => Major.find(:first)
                                }

    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_equal num_users + 1, User.count
  end
  
  def test_register_duplicate_email
    num_users = User.count

    post :register, :user => {  :username=>'nikhil', 
                                :password=>'sonie123',
                                :first_name=>'abcd',
                                :last_name=>'cdef', 
                                :email=>'nsonie2@uiuc.edu',
                                :start_year=>'2009',
                                :start_sem=>'FA', 
                                :birthday=>'1990-10-29', 
                                :college => College.find(:first),
                                :major => Major.find(:first)
                                }

    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_equal num_users + 1, User.count
    
    #now create a second user with the same email
    post :register, :user => {  :username=>'chorneck', 
                                :password=>'illinwek',
                                :first_name=>'abcd',
                                :last_name=>'cdef', 
                                :email=>'nsonie2@uiuc.edu',
                                :start_year=>'2009',
                                :start_sem=>'FA', 
                                :birthday=>'1990-10-29', 
                                :college => College.find(:first),
                                :major => Major.find(:first)
                                }
    # Make sure the register page is returned instead of a redirect
    assert_response :success
    assert_template "profile/register"    
    
  end
  
  def test_edit
    get :edit

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
  end
  
  def test_edit_submit
    post:edit, :id=>1, :user => {:username=>'nikhil', 
                                :password=>'sonie123',
                                :first_name=>'abcd',
                                :last_name=>'cdef', 
                                :email=>'nsonie2@uiuc.edu',
                                :start_year=>'2009',
                                :start_sem=>'FA', 
                                :birthday=>'1990-10-29', 
                                :college => College.find(:first),
                                :major => Major.find(:first)
                                }    
  
    assert_response :redirect
    assert_redirected_to :controller=>'profile', :action=>'show'
    
    assert_not_nil assigns("user")
    
    assert User.exists?(:username=>'nikhil', :first_name=>"abcd", :last_name=>"cdef",:email=>'nsonie2@uiuc.edu')
     
  end
  
  def test_edit_submit_withoutpassword
  post:edit, :id=>1, :user => {:username=>'nikhil', 
                                :password=>'',
                                :first_name=>'abcd',
                                :last_name=>'cdef', 
                                :email=>'nsonie2@uiuc.edu',
                                :start_year=>'2009',
                                :start_sem=>'FA', 
                                :birthday=>'1990-10-29', 
                                :college => College.find(:first),
                                :major => Major.find(:first)
                                }    
  
    assert_response :redirect
    assert_redirected_to :controller=>'profile', :action=>'show'
    
    assert_not_nil assigns("user")
    
    assert User.exists?(:username=>'nikhil', :first_name=>"abcd", :last_name=>"cdef",:email=>'nsonie2@uiuc.edu')
     
  end
  
  def test_edit_college_major
    post :edit, :id => 1, :user => {:username =>'james',
                                    :password => '',
                                    :first_name => 'nikhil',
                                    :last_name => 'sonie',
                                    :email => 'mirani@uiuc.edu',
                                    :birthday => '1985-02-17',
                                    :college_id => 4,
                                    :major_id => 54}
   
    assert_response :redirect
    assert_redirected_to :controller=>'profile', :action=>'show'
    
    assert_not_nil assigns("user")
    
    assert User.exists?(:username=>'james', :first_name=>'nikhil', :last_name=>'sonie',:email=>'mirani@uiuc.edu', :college_id => 4, :major_id => 54)
       
  end    
  
  def test_edit_name
    post :edit, :id => 1, :user => {:username => 'james',
                                    :password => '',
                                    :first_name => 'Kailey',
                                    :last_name => 'Szalko'}
    
    assert_response :redirect
    assert_redirected_to :controller => 'profile', :action => 'show'
    assert User.exists?(:username => 'james', :first_name => 'Kailey', :last_name => 'Szalko')
    
    #make sure edited name now displayed on profile
    get :show, :id =>1
    assert_select "td", :count => 1, :text => "Kailey Szalko"
  end

  def test_destroy
    assert_not_nil User.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => 'login'

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(1)
    }
  end
  
  def test_destroy_cleanup
    assert_not_nil User.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :controller => 'login'

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(1)
    }
    
    aUser = User.find(3)
    assert_not_nil aUser
    
    #Make sure friends are cleaned up
    assert !aUser.friends.exists?(1)
    assert aUser.friends.exists?(2)
    
    #Make sure coursebin is deleted
    assert !CourseBin.exists?(1)
    
    #Make sure semesters are deleted
    assert !Semester.exists?(:user_id=>1)
  end
  
  def test_destroy_reuse_email
     assert_not_nil User.find(1)

     post :destroy, :id => 1
     assert_response :redirect
     assert_redirected_to :controller => 'login'
     assert_raise(ActiveRecord::RecordNotFound) {
      User.find(1)
    }
    
    # now we should be able to reuse the email for the user_id 1 from the fixtures
    num_users = User.count
    post :register, :user => {  :username=>'nikhil', 
                                :password=>'sonie123',
                                :first_name=>'abcd',
                                :last_name=>'cdef', 
                                :email=>'mirani@uiuc.edu',
                                :start_year=>'2009',
                                :start_sem=>'FA', 
                                :birthday=>'1990-10-29', 
                                :college => College.find(:first),
                                :major => Major.find(:first)
                                }

    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_equal num_users + 1, User.count
  end
end
