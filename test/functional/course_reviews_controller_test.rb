require File.dirname(__FILE__) + '/../test_helper'
require 'course_reviews_controller'

# Re-raise errors caught by the controller.
class CourseReviewsController; def rescue_action(e) raise e end; end

class CourseReviewsControllerTest < Test::Unit::TestCase
  fixtures :cis_courses, :users, :course_reviews
  
  def setup
    @controller = CourseReviewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = 1
    @request.env["HTTP_REFERER"] = "/coursereviews/list/1"    
  end

  
  def test_post
    course_id = 1
  
    review_count = CisCourse.find(course_id).course_reviews.size
    post :post, {:id => course_id, :course_review=>{:title=>"Title", :body=>"Body"}}
    
    assert(CisCourse.find(course_id).course_reviews.size > review_count)
    
    review = CisCourse.find(course_id).course_reviews[-1]
    assert review.title == "Title"
    assert review.body =="Body"
    assert review.user == User.find(@request.session[:user])
    assert review.cis_course == CisCourse.find(1) 
  
    assert_response :redirect
  end
  
    def test_post_another_way      
      post :post, {:id => 3, :course_review=>{:title=>"test", :body=>"test"}}
      assert_response :redirect
      my_review = CourseReview.find(:first, :conditions=>{:cis_course_id=>3})
      assert_equal my_review.title,"test"
      assert_equal my_review.body,"test"
      assert_equal my_review.user_id,1      
    end
    
   def test_post_nil_id
      post :post, {:id => nil, :course_review=>{:title=>"test", :body=>"test"}}
    
   end
    
  
  
  def test_post_nil
    get :post, {:id=>nil}
  
  end
  
  def test_list
    get :list, {'id'=>"1"}
    assert_response :success
  end
  
  def test_list_nil
    get :list
    assert_response :success    
  end
end
