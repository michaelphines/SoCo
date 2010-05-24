require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

  end

  #gets the index page successfully?
  def test_index
    get :index
    assert_response :success
  end
  
    #check for login success
  def test_login_success
    get :validate, :user=>"james", :pass=>"bondness"
    assert_not_nil assigns["user"]
    assert_equal 1, assigns["user"].id
    assert_equal 1, session[:user]
    assert flash.empty?   
  end   
  
    
  #check for login failure
  def test_login_failure
    get :validate, :user=>"nikhil", :pass=>"sonie"
    assert_nil assigns["user"]
    assert_nil session[:user]
    assert_not_nil flash[:error]
    assert_equal "Invalid user name or password.", flash[:error]
  end
  
 def test_password_field
    post :validate, "user"=>"nikhil", "pass"=>"son"
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal false,  flash.empty?
    assert_equal "Invalid user name or password.", flash[:error]
  end
  
  def test_nil_password_field
    post :validate, "user"=>"nikhil", "pass"=>""
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal false,  flash.empty?
    assert_equal "Invalid user name or password.", flash[:error]
  end
  
  def test_nil_username_nil_password
    post :validate, "user"=>"", "pass"=>""
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal false,  flash.empty?
    assert_equal "Invalid user name or password.", flash[:error]
  end
  
  def test_big_username
    j = "c"
    for i in 1..257
       j.concat("c")
    end
    
    post :validate, "user"=>j, "pass"=>"sonie123"
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal false,  flash.empty?
    assert_equal "Invalid user name or password.", flash[:error]
  end
  
  def test_nil_username
    post :validate, "user"=>"", "pass"=>"temp123"
    assert_response :redirect
    assert_redirected_to :action => 'index'
    assert_equal false,  flash.empty?
    assert_equal "Invalid user name or password.", flash[:error]
  end
  
  def test_logout
    get :logout
    assert :success
  end

#system test
 def test_loginSystem
    get :index
    assert_response :success
  
#check for login success
    get :validate, :user=>"james", :pass=>"bondness"
    assert_not_nil assigns["user"]
    assert_equal 1, assigns["user"].id
    assert_equal 1, session[:user]
    assert flash.empty?   

#check for login failure
    get :logout
    assert :success

#check for login failure
    get :validate, :user=>"nikhil", :pass=>"sonie"
    assert_nil assigns["user"]
    assert_nil session[:user]
    assert_not_nil flash[:error]
    assert_equal "Invalid user name or password.", flash[:error]
  end
end
