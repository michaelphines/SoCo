class FriendsController < ApplicationController
  #list logged in user's friends
  def index
    redirect_to(:action => "list")
  end

  #search for user by string
  def search
    @user = User.find session[:user]
    if (params[:q])
      @friends = User.search(params[:q])
    else
      @friends = []
    end
    render :action => 'list'
  end
  
  #list logged in user's friends
  def list
    @user = User.find session[:user]
    @friends = @user.friends
  end
  
  #list all users
  def browse
    @title = "Browse Users"
    @paginate = true
    @user = User.find session[:user]
    @user_count = User.count_by_sql "SELECT COUNT(*) FROM users"
    @friends, @friends_page = User.paginate :all, :order => 'last_name ASC, first_name ASC', :page => params[:page]
    render :action => 'list'
  end

  #add a friend to the logged in user by id
  def add
    user = User.find session[:user]
    friend = User.find params[:id]
    
    redirect_to :back
    
    if user != friend
      if !user.friends.exists?(params[:id])
        user.friends.concat friend
        friend.friends.concat user
      else
        flash[:error] = 'Sorry, you cannot add the same friend more than once.'
      end
    else
      flash[:error] = 'Sorry, you cannot be your own friend.'
    end
    
  end
 
  #remove a friend from the logged in user by id
  def remove
    user_id = session[:user]
    friend_id = params[:id]

    redirect_to :back

    #user = User.find session[:user]
    #friend = User.find params[:id]

    Relationship.delete_all ["(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)", user_id, friend_id, friend_id, user_id]
    
    #WARN
    #broken in rails
    #user.friends.delete friend
    #friend.friends.delete user
  end
end
