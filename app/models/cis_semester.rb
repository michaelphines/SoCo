class CisSemester < ActiveRecord::Base
  has_many :cis_sections
  belongs_to :cis_course

  #get the word for this semester (mainly for use in html links)
  def semester_word
    case semester
      when :SP
        "Spring"
      when :FA
        "Fall"
      when :SU
        "Summer"
    end
  end
end
