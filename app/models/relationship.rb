class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  has_many :shared_courses, :dependent => :destroy
  
  #gets a relationship by a +user_id+ and a +friend_id+
  def self.find_by_user_and_friend(user_id, friend_id)
    find :first, :conditions => {:user_id => user_id, :friend_id => friend_id}
  end
end
