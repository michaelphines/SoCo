require File.dirname(__FILE__) + '/../test_helper'
require 'register_controller'

# Re-raise errors caught by the controller.
class RegisterController; def rescue_action(e) raise e end; end

class RegisterControllerTest < Test::Unit::TestCase
  fixtures :cis_courses, :users, :semesters, :cis_semesters
  
  def setup
    @controller = RegisterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = 1
  end

  def test_list_crns
    get :list_crns, {'id'=>"1"}
    assert_not_nil assigns(:crns)
    assert_response :success
  end
  

end
