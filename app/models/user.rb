require 'digest/sha1'

class User < ActiveRecord::Base
  attr_accessor :password
  cattr_reader :per_page
  @@per_page = 20

  has_one :course_bin, :dependent => :destroy
  has_many :semesters, :dependent => :destroy, :order => 'year ASC, semester ASC'
  belongs_to :college
  belongs_to :major
  has_many :relationships, :dependent => :destroy
  has_many :friends, :through => :relationships, :order => 'last_name ASC, first_name ASC'
  has_many :course_reviews
  
  
  validates_uniqueness_of :username, :email
  validates_presence_of :username, :start_sem, :start_year, :college, :major, :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_length_of :password, :within => 6..40, :if => :needs_password_update?
  validates_confirmation_of :password, :if => :needs_password_update?
  validates_date :birthday

  before_save :encrypt_password
  after_create :create_dependencies
  after_destroy :delete_associated_relationships
  
  #checks for successful authentication with a +username+ and +password+
  def self.authenticate(username, password)
    find(:first, 
      :conditions => {:username => username, :password_hash => Digest::SHA1.hexdigest(password)}
    )
  end

  #Given Surname
  def to_s
    return first_name + " " + last_name
  end
  
  #returns a combined list of all courses which this user is taking 
  def courses
    course_list = []
    
    semesters.collect do |semester|
      course_list << semester.cis_courses
    end
    
    course_list << course_bin.cis_courses
    
    return course_list
  end
  
  #determines whether the user is taking the course in a semester or in course bin
  def has_course?(course_id)
    semesters.collect do |semester|
      if semester.cis_courses.exists?(course_id)
        return true
      end 
    end
  
    return course_bin.cis_courses.exists?(course_id)
  end

  #finds users by first_name, last_name, username, or email
  def self.search(query)
    if query == ""
      return []
    end
      
    terms = query.split
    fields = ['first_name', 'last_name', 'username', 'email']
    
    fields.collect! {|field| field += " LIKE ?"}
    
    query_string_short = fields.join " OR "
    
    query_string = []
    
    terms.each {|term| query_string.push query_string_short}
    
    conditions = [query_string.join(" AND "),]
    
    terms.each {|term| fields.each {|field| conditions.push '%' << term << '%' } }
    
    users = find :all, 
      :order => 'last_name ASC, first_name ASC',
      :conditions => conditions,
      :limit => 100
    
    return users   
  end

  private
  #sets the password hash
  def encrypt_password
    unless password.empty?
      self.password_hash = Digest::SHA1.hexdigest(password)
    end
  end

  #determines whether the password hash should be updated in database
  def needs_password_update?
    password_hash.empty? or not password.empty?
  end
  
  #creates course bin and 8 semesters upon creation of this object
  def create_dependencies
    create_course_bin()

    #create 8 default semesters
    Semester.create_semesters(start_sem, start_year.to_i, 8) {|semester| semesters.concat semester} 
  end

  def delete_associated_relationships
    associated = Relationship.find :all, :conditions => {:friend_id => id}
    
    associated.each { |rel| rel.destroy }
  end  
end
