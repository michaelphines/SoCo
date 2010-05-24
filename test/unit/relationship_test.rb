require File.dirname(__FILE__) + '/../test_helper'

class RelationshipTest < Test::Unit::TestCase

 fixtures :users, :relationships, :course_bins, :semesters, :colleges, :majors

# this test shows that when you initialize a new user, he has no friends by default   
  def test_zerofriends
    user = User.new(
            :first_name=>'forest',
            :last_name=>'gump',
            :username=>'forest',
            :password=>"gump123",
            :email=>"fgump@uiuc.edu",
            :start_year=>'2009',
            :start_sem=>'FA',
            :birthday=>'1990-10-29',
            :college => College.find(:first),
            :major => Major.find(:first)
          )
    assert_nothing_raised { user.save! }
    assert_equal(user.friends, [])
  end

#  this test shows that you can be your own friend
  def test_NoRestrictionsBeingMyOwnFriend
    this_user_found = false;
    user = User.new(
            :first_name=>'forest',
            :last_name=>'gump',
            :username=>'forest',
            :password=>"gump123",
            :email=>"fgump@uiuc.edu",
            :start_year=>'2009',
            :start_sem=>'FA',
            :birthday=>'1990-10-29',
            :college => College.find(:first),
            :major => Major.find(:first)
          )
    assert_nothing_raised { user.save! }
    user.friends.concat user
    user.friends.each do |eUser |
      if(eUser.id == user.id)
        this_user_found = true
      end
    end
    assert this_user_found
  end
  
#  this test shows that you can all user's excluding this user
  def test_addFriends
    user1 = User.new(
            :first_name=>'forest',
            :last_name=>'gump',
            :username=>'forest1',
            :password=>"gump123",
            :email=>"fgump1@uiuc.edu",
            :start_year=>'2009',
            :start_sem=>'FA',
            :birthday=>'1990-10-29',
            :college => College.find(:first),
            :major => Major.find(:first)
          )
    user2 = User.new(
            :first_name=>'forest',
            :last_name=>'gump',
            :username=>'forest2',
            :password=>"gump123",
            :email=>"fgump2@uiuc.edu",
            :start_year=>'2009',
            :start_sem=>'FA',
            :birthday=>'1990-10-29',
            :college => College.find(:first),
            :major => Major.find(:first)
          )
    assert_nothing_raised { user1.save! }
    assert_nothing_raised { user2.save! }
    @friends_all = User.find :all, :order => 'last_name ASC, first_name ASC'  
    @friends_all.each do |eUser|
      if(eUser.id != user1.id) 
        friend = User.find eUser.id
        user1.friends.concat friend
      end
    end
    
    #shouldn't be friends with self
    assert_equal(@friends_all.size - 1, user1.friends.length)
  end
end
