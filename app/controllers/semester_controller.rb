# vim: tabstop=2 shiftwidth=2 expandtab

# tree for generating all possible schedules
class BoolTree
  def solve
  end
  def initialize(children = [])
    @children = children
    @solution = []
  end
  def add_child(child)
    @children.push child
  end
end

# choose one from each child
class And < BoolTree
  def solve
    !@solution.empty? and return @solution

    @children.each do |c|

      if @solution.empty?
        @solution = c.solve
        next
      end

      new_solution = []
      c.solve.each do |a|
        @solution.each do |b| 
          c = a + b and new_solution.push c
        end
      end
      @solution = new_solution
    end
    @solution
  end
end
      
# choose one from one child
class Or < BoolTree
  def solve
    #@solution = (@solution.empty? && @children.collect { |c| c.solve }) || @solution
    !@solution.empty? and return @solution

    @children.each { |c|
      @solution += c.solve
    }
    @solution
  end
end

# leaves contain OptionSets, which is an array of sections
class Leaf < BoolTree
  def solve
    @solution
  end
  def initialize(opset)
    @children = nil
    @solution = [OptionSet.new([opset])]
  end
end

# a solution is an array of option sets, 
# an option set is an array of options (sections)
# basically an array that detects schedule collisions
class OptionSet
  attr_reader :option_set
  def initialize(set = [])
    @option_set = set
#           @conflict_matix = []

#           set.each do |s|
#                 s.days.each_byte do |b|
#                       (s.endTime - s.startTime) / (15 * 60)
#                       @conflict_matrix[b] 
#                 end
#           end
  end
  # ugly conflict detection
  def +(b)
    b.option_set.each do |y|
      @option_set.each do |x|
        x.days.split(//).each do |day|
          if y.days.include? day
            if y.startTime < x.endTime && y.startTime >= x.startTime \
            || x.startTime < y.endTime && x.startTime >= y.startTime
              return nil
            end
          end
        end
      end
    end
    OptionSet.new(@option_set + b.option_set)
  end
end

class SemesterController < ApplicationController

  # show semester schedule
  def show
    @semester = Semester.find(params[:id])

    @start_time = DateTime.new(0,1,1,8)
    @end_time = DateTime.new(0,1,1,21,30)
    @time_inc = 15/(24.0*60) #15.0/(24.0*60.0)

    session[:solution] = nil
    session[:marker] = nil
    #        time.strftime("%H:%M")
  end

  # add/remove section from semester schedule
  def toggle_section

    # friend is viewing schedule
    if Semester.find(params[:id]).user.id.to_s != session[:user].to_s
      render :nothing => true
      return
    end

    user = User.find session[:user]
    section = CisSection.find(params[:section])
    plan = user.semesters.find(params[:id]).course_plan

    if plan.cis_sections.exists? params[:section]
      plan.cis_sections.delete section
    else
      plan.cis_sections.concat section
    end

    @semester = Semester.find(params[:id])

    # TODO clean this up
    @start_time = DateTime.new(0,1,1,8)
    @end_time = DateTime.new(0,1,1,21,30)
    @time_inc = 15/(24.0*60)
    @courses = @semester.cis_courses
    @plan = @semester.course_plan
    course = section.cis_semester.cis_course

    sections = course.sections_for_semester @semester

    render :update do |page|
      page.replace_html 'times_row', :partial => 'times_row', :locals => {:semester => @semester}
      page.replace_html "sects_#{@semester.id}_#{course.id}", :partial => 'section_choice', :collection => sections, :locals => {:semester => @semester}
    end
  end

  NPREVIEWS = 6

  # display the next generated schedules
  def generate_next
    session[:solution] == nil && generate

    session[:marker] += NPREVIEWS

    if session[:marker] >= session[:solution].length
      session[:marker] = 0
    end

    session[:solution] && load_sections
  end

  # display the previous generated schedules
  def generate_prev
    session[:solution] == nil && generate
   
    session[:marker] -= NPREVIEWS

    if session[:marker] < 0
      if session[:solution].length.remainder(NPREVIEWS) == 0
        session[:marker] = session[:solution].length - NPREVIEWS
      else
        session[:marker] = session[:solution].length - session[:solution].length.remainder(NPREVIEWS)
      end
    end

    session[:solution] && load_sections
  end

  # select a schedule from the previews window
  def select_solution
    if session[:solution]
      load_sections(params[:chosen] && params[:chosen].to_i)
    else
      render :nothing => true
    end
  end

  # generate schedules and show the previews window
  def show_previews
    session[:solution] == nil && generate
    load_sections(nil, true)
  end
    
  private

  # load the selected generated schedule
  def load_sections(solution_to_load = nil, show_previews = false)

    user = User.find session[:user]
    plan = user.semesters.find(params[:id]).course_plan
    semester = Semester.find(params[:id]);
    courses = semester.cis_courses

    if solution_to_load
      plan.cis_sections.delete plan.cis_sections
      plan.cis_sections.concat session[:solution][solution_to_load]
    end

    # previews stuff
    npreviews = 6
    @solutions = session[:solution]

    @total_width = 100
    @total_height = 100
    padding_horiz = 5
    padding_vert = 5
    ndays = 6
    nhours = 15
    @start_hour = 8

    @seconds_per_pixel = nhours * 60 * 60 / (@total_height - 2 * padding_vert)

    @width = (@total_width - 2 * padding_horiz)/ ndays

    @day_left = {
      'M' => 0,
      'T' => @width,
      'W' => @width * 2,
      'R' => @width * 3,
      'F' => @width * 4,
      'S' => @width * 5,
    }

    if !session[:generator_error] && (!session[:solution] || session[:solution].length == 0)
      session[:generator_error] = 'No possible schedules (Click here to close).'
    end

    render :update do |page|
      if solution_to_load
        page.replace_html 'times_row', :partial => 'times_row', :locals => {:semester => semester}
        courses.each do |course|
          if course.sections_for_semester(semester) && course.sections_for_semester(semester).length != 0
            page.replace_html "sects_#{semester.id}_#{course.id}", :partial => 'section_choice', :collection => course.sections_for_semester(semester), :locals => {:semester => semester}
          end
        end
      else
        if session[:generator_error]
          page.replace_html 'generator_error', session[:generator_error]
        else
          page.replace_html 'previews_list', :partial => 'solution', :collection => @solutions[session[:marker], npreviews]
        end
      end
      if show_previews
        page.visual_effect :toggle_blind, 'previews_window'
      end
    end
  end

  # generate all possible schedules
  # another possible improvement would be to generate one schedule at a
  # time and not all at once
  def generate
    session[:generator_error] = nil
    semester = Semester.find(params[:id]);
    courses = semester.cis_courses

    # decide whether we should try to generate
    nsections = 0
    ncourses = courses.length
    courses.each do |c| 
      cis_semester = c.cis_semesters.find(:first, :conditions => ['year = ? AND semester = ?', semester.year, semester.semester])
      sections = cis_semester && cis_semester.cis_sections && cis_semester.cis_sections.sort {|a, b| a.name <=> b.name}
      if sections == nil then next end
      nsections += sections.length
    end
    score = nsections

    # disable generation if it looks like we're going to spin too long
    if score > 120
      session[:solution] = nil
      session[:marker] = 0
      # flash error here
      session[:generator_error] = 'Generator disabled (schedule appears to be too complicated for server-side generation, click here to close).'
      return
    end

    root = And.new


    courses.each do |c|
      cis_semester = c.cis_semesters.find(:first, :conditions => ['year = ? AND semester = ?', semester.year, semester.semester])
      sections = cis_semester && cis_semester.cis_sections && cis_semester.cis_sections.sort {|a, b| a.name <=> b.name}
      if !sections || sections.length == 0 then next end

      if sections[0].name.length == 0
        orob = Or.new
        sections.each do |s|
          orob.add_child Leaf.new(s)
        end
        root.add_child orob

      elsif sections[0].name.length == 1
        orob = Or.new
        andob = And.new
        mark = sections[0].name[0]

        sections.each do |s|
          if s.name[0] != mark
            mark = s.name[0]
            orob.add_child andob
            andob = And.new
          end
          andob.add_child Leaf.new(s)
        end

        orob.add_child andob
        root.add_child orob

      else # length 2 or 3
        
        l1or = Or.new
        l2and = And.new
        l3or = Or.new

        mark0 = sections[0].name[0]
        mark1 = sections[0].name[1]

        sections.each do |s|

          if s.name[0] != mark0
            mark0 = s.name[0]
            mark1 = s.name[1]
            l2and.add_child l3or
            l1or.add_child l2and
            l3or = Or.new
            l2and = And.new
          elsif s.name[1] != mark1
            mark1 = s.name[1]
            if s.name.length == 3
              l2and.add_child l3or
              l3or = Or.new
            end
          end
          l3or.add_child Leaf.new(s)
        end

        l2and.add_child l3or
        l1or.add_child l2and
        root.add_child l1or
      end

    end

    session[:solution] = root.solve.collect { |opset| opset.option_set }
    session[:marker] = 0
  end

end

