class CourseDependency < ActiveRecord::Base
  acts_as_graph :edge_table => 'course_dependency_edges'
  has_many :cis_courses
  
  #returns a textual representation of this course's dependencies
  def to_s
    courses = []
    children.each { |child| courses.push child.to_s_helper }
    
    if node_type == :CONCURRENT
      return "concurrently with " << courses.join(" and ")
    elsif node_type == :OR
      return courses.join(" or ")
    end
    
    #type is either COURSE or AND
    
    return courses.join(" and ")
  end
  
  #returns whether this dependency has been satisfied for the specified
  #+semester_id+, and +user+
  def is_satisfied?(semester_id, user)
    children.each do |child|
      if not child.is_satisfied_helper?(semester_id, user)
        return false
      end
    end

    return true
  end
  
  protected
  def is_satisfied_helper?(semester_id, user)
    case node_type
      when :COURSE
        return course_is_in_earlier_semester?(semester_id, user) 
      when :OR
        children.each do |child|
          if child.is_satisfied_helper?(semester_id, user)
            return true
          end
        end
        return children.empty?
      when :AND
        children.each do |child|
          if not child.is_satisfied_helper?(semester_id, user)
            return false
          end
        end
        return true
      else #:CONCURRENT
        children.each do |child|
          if not child.is_satisfied_helper?(semester_id + 1, user)
            return false
          end
        end
        return true
    end
  end
  
  def to_s_helper
    if node_type == :COURSE
      return cis_courses[0].to_s
    end
    
    return "(" + to_s + ")"
  end
  
  #returns whether the current node of type COURSE can be found in an earlier semester than +max_semester_id+ for +user+
  def course_is_in_earlier_semester?(max_semester_id, user)
    raise TypeError unless node_type == :COURSE

    user.semesters.each do |semester|
      if semester.id == max_semester_id
        break
      end
      semester.cis_courses.each do |course|
        if course.course_dependency.id == id
          return true
        end
      end
    end

    return false
  end
end
