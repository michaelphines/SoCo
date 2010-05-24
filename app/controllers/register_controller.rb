class RegisterController < ApplicationController

  #lists the CRNS for a particular semseter
  def list_crns
    user = User.find session[:user]
    plan = user.semesters.find(params[:id]).course_plan

    @crns = plan.cis_sections.collect { |s| s.crn }
  end

  def register
  end
end
