class CourseReviewsController < ApplicationController

  #list all reviews for a course
  def list
    course_id = params[:id]
    
    if course_id.nil?
      render :text => "You must specify a course id"
      return
    end
    
    @course = CisCourse.find(course_id)
    
    @reviews = CisCourse.find(course_id).course_reviews
  end

  #post a new message to a course
  def post
    course_id = params[:id]
    
    if course_id.nil?
      render :text => "You must specify a course id"
      return
    end    

    review = CourseReview.new(params[:course_review])
    review.cis_course = CisCourse.find course_id
    review.user = User.find session[:user]
    review.save

    redirect_to :back
  end
end
