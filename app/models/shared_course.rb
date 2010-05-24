class SharedCourse < ActiveRecord::Base
  belongs_to :relationship
  belongs_to :cis_course
  
  #get the friend of +user+ for this shared course
  def get_friend(user)
    #look at relationship
    
    if relationship.user.id == user.id
      return relationship.friend
    else
      return relationship.user
    end
  end
end
