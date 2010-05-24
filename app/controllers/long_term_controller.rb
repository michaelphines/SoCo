class LongTermController < ApplicationController
  #show the currently logged in user's long term view
  def index
    @user = User.find session[:user]
    @course_bin_courses = @user.course_bin.cis_courses
    @semesters = @user.semesters.find :all
  end
  
  #show someone's long term view
  def show
    @user = User.find params[:id]
    if @user == nil
      redirect_to :action => 'index'
      return
    end
    
    @course_bin_courses = @user.course_bin.cis_courses
    @semesters = @user.semesters.find :all
  end
  
  #remove a course from semester or course bin
  def remove
    user = User.find session[:user]
    @course_id = params[:course_id].to_i
    @semester_id = params[:semester_id].to_i
    course = CisCourse.find(@course_id)
    
    
    if @semester_id == -1
      user.course_bin.cis_courses.delete(course)
    else
      semester = Semester.find(@semester_id)
      semester.cis_courses.delete(course)
      # sections from semester plan
      course.sections_for_semester(Semester.find(@semester_id)) and user.semesters.find(@semester_id).course_plan.remove_cis_sections course.sections_for_semester(Semester.find(@semester_id))
    end
  end

  #add a class to course bin
  def add_class
    @user = User.find session[:user]
    class_id = params[:course][:number]  
    class_id.upcase!
    (subject, white, number) = class_id.scan(/^([A-Z]*)(\s*)(\d*)$/)[0]           
    
    if subject.nil? 
      flash[:error] = "Invalid Course"
      render :action => 'ajax_flash'
      return
    else
      if number.blank? && white.empty?
        flash[:error] = "Invalid Course"
        render :action => 'ajax_flash'
        return
      else
        results = CisSubject.search_for_course(class_id)
        if results.size == 1
          @course = CisCourse.find results[0].id
          @user.course_bin.cis_courses.concat @course
        else
          flash[:error] = "Invalid Course"
          render :action => 'ajax_flash'
          return
        end
      end
    end
  end
  
  #move a class from one semester to another
  def update_semester
    @user = User.find session[:user]
    course = CisCourse.find(params[:id].split('_')[2].to_i)
    new_semester_id = params[:new_semester].to_i
    old_semester_id = params[:id].split('_')[1].to_i

    if old_semester_id == -1
      @user.course_bin.cis_courses.delete(course)
    else
      course.semesters.delete(Semester.find(old_semester_id))
      # remove sections from old semester
      course.sections_for_semester(Semester.find(old_semester_id)) and @user.semesters.find(old_semester_id).course_plan.remove_cis_sections course.sections_for_semester(Semester.find(old_semester_id))
    end
    if new_semester_id == -1
      @user.course_bin.cis_courses.concat(course)
    else
      course.semesters.concat(Semester.find(new_semester_id))
    end

    if new_semester_id != -1
      semester_obj = Semester.find(new_semester_id)
    end

    render :partial => 'course', :object => course, :locals => {:semester_obj => semester_obj || nil, :effect => true}
  end
  
  #autocomplete the course name
  def auto_complete_for_course_number
    flash.keep
    @courses = CisSubject.search_for_course(params[:course][:number])
    render :partial => 'auto_complete_course'
  end

  #take a course with a friend
  #called from either own view or friend's view
  #display's list of friends if initiated from own view
  def take_course_with_friend
    current_user = User.find session[:user]
    course_id = params[:course_id].to_i
    semester_id = params[:semester_id].to_i
    friend_id = params[:friend_id].to_i
    
    #if friend id isn't set, then we're in our own view
    if friend_id == session[:user]
      #prompt for name in view
      @course = CisCourse.find course_id
      if (semester_id != -1)
        @semester = Semester.find semester_id
      else
        @semester = nil
      end
      @friends = current_user.friends
    else
      #we're in friends view
      #redirect
      redirect_to :back      
      
      #add course to your schedule in same semester
      
      if semester_id == -1
        #course bin
        semester = nil
      else
        orig_semester = Semester.find semester_id
        
        semester = current_user.semesters.find :first, :conditions => {:year => orig_semester.year, :semester => orig_semester.semester}
      end
      
      if not current_user.has_course? course_id
        if not semester.nil?
          semester.cis_courses << (CisCourse.find course_id)
        else
          #course bin if semester doesn't exists
          current_user.course_bin.cis_courses << (CisCourse.find course_id)
        end
      end

      #create shared course object
      create_and_link_shared_course friend_id, course_id
    end
  end
  
  #second step of taking course with friend initiated from own view
  def take_my_course_with_friend
    #course id
    course_id = params[:course_id].to_i

    #get selected friends
    selected_friends = params[:friends]
    
    #redirect
    redirect_to :action => 'index'
    if selected_friends == nil
      flash[:error] = "You must select a friend to take this course with."
      return
 	end
  	selected_friends.each do |friend_id|
  	  
  	  friend_id = friend_id.to_i
  	  
  	  friend = User.find friend_id
  	  
  	  #check to see if friend already has course
  	  if not friend.has_course? course_id
  	    #place in friend's course bin otherwise
  	    friend.course_bin.cis_courses << (CisCourse.find course_id)
  	  end
  	
  	  #created shared course object
  	  create_and_link_shared_course friend_id, course_id
  	end
  end
  
  #removes a shared course link
  #only does so in one way (friend will still share the course with you)
  def delete_shared_course
    shared_course_id = params[:id]
    
    SharedCourse.delete(shared_course_id)
  
    redirect_to :back
  end

  #adds a semester to the user's schedule at the end
  def push_semester
    redirect_to :action => 'index'
    
    current_user = User.find session[:user]
    
    if not current_user.semesters.empty?
      last_semester = current_user.semesters[-1]
      start_sem, start_year = last_semester.get_next_semester_and_year
    else
      start_sem = current_user.start_sem
      start_year = current_user.start_year
    end
    
    Semester.create_semesters(start_sem, start_year, 1) {|semester| current_user.semesters << semester}
  end
  
  #removes the last semester from the user's schedule
  def pop_semester
    redirect_to :action => 'index'
    
    current_user = User.find session[:user]
    
    if not current_user.semesters.empty?
      last_semester = current_user.semesters[-1]
      current_user.semesters.delete last_semester
    end
  end

  #checks for prerequisites and sends an RJS update back to the client
  def update_prerequisites
    @user = User.find session[:user]
  end

  private
  #create a shared course (+course_id+) between the logged in user and +friend_id+
  def create_and_link_shared_course friend_id, course_id
    user_id = session[:user]
    user_friend_relationship = Relationship.find_by_user_and_friend(user_id, friend_id)
    friend_user_relationship = Relationship.find_by_user_and_friend(friend_id, user_id)
    
    if not user_friend_relationship.nil? and not friend_user_relationship.nil?
      if user_friend_relationship.shared_courses.exists? :cis_course_id => course_id
        flash[:error] = "You are already taking this course with your friend"
      else
        user_friend_relationship.shared_courses.create :cis_course_id => course_id
      end
      if not friend_user_relationship.shared_courses.exists? :cis_course_id => course_id
        friend_user_relationship.shared_courses.create :cis_course_id => course_id
      end
    end
  end
end
