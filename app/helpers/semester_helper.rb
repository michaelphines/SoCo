module SemesterHelper
  def classes day, semester
    semester == -1 && return
    @semester = Semester.find(semester)
    render :partial => 'section', 
      :collection => @semester.course_plan.cis_sections.find(:all, 
      :conditions =>["days LIKE ?",'%'+day+'%'])
  end

  def section_in_plan?(section, semester)
        begin
              Semester.find(semester).course_plan.cis_sections.find section
        rescue
              return false
        else
              return true
        end
  end


end
