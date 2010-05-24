class CisSubject < ActiveRecord::Base
  has_many :cis_courses
  
  #static method which finds a course written textually
  def self.search_for_course(name)
    name.upcase!
    
    (subject, white, number) = name.scan(/^([A-Z]*)(\s*)(\d*)$/)[0]

    if subject == nil
      return []
    end

    if number.blank? && white.empty?
      subjects = find :all,
        :conditions => [ 'cis_subjects.code LIKE ?', subject + '%' ],
        :limit => 10
        
    else
      subjects = find :all,
        :conditions => [ 'cis_subjects.code = ? AND cis_courses.number LIKE ?',
                          subject,
                          number + '%' ],
        :joins => "LEFT JOIN cis_courses ON cis_courses.cis_subject_id = cis_subjects.id",
        :limit => 10
    end
    
    return subjects    
  end
  
  #returns SUBJECT
  def to_s
    return code
  end
end
