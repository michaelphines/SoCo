require File.dirname(__FILE__) + '/../test_helper'
require 'facebook_controller'

# Re-raise errors caught by the controller.
class FacebookController; def rescue_action(e) raise e end; end

class FacebookControllerTest < Test::Unit::TestCase
  def setup
    @controller = FacebookController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = 1
  end
  
  def test_index
    post :index
    assert_response :redirect
    assert_redirected_to :action => "start_session"
  end
  
  def test_start_session
    post  :start_session
    assert_response :redirect
    assert_redirected_to session[:facebook_session].get_login_url    
  end
  
end
