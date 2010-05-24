
class FacebookController < ApplicationController
  def index
      redirect_to(:action => "start_session")
  end
  
  #create a facebook session by prompting the user to login to facebook
  def start_session
    session[:facebook_session] = RBook::FacebookWebSession.new('db204644ba402b4d86ac2886372a96bf', '776bfd48e704d1e64f1dcaf24c867bc5')
    redirect_to session[:facebook_session].get_login_url    
  end
    
  #get a list of friends from facebook and add to logged in user's friends list
  #run from facebook
  def friends_get
    begin
      session[:facebook_session].init_with_token(params[:auth_token])
    rescue RBook::FacebookSession::RemoteException => e
      flash[:error] = "An exception occurred while trying to authenticate with Facebook: #{e}"
      redirect_to :controller => 'profile', :action => 'show'
      return
    end
    
    begin
      #this is queued up, not taken immediately
      redirect_to :controller => 'profile', :action => 'show'
      
      uid = session[:facebook_session].session_uid
      
      current_user = User.find session[:user]
      
      #do we want to add "AND is_app_user"?
      myResponse = session[:facebook_session].fql_query({:query => "SELECT first_name, last_name FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=#{uid})"})
      
      (myResponse/"//user").each do |user|
        first_name = user.at("first_name").inner_html
        last_name = user.at("last_name").inner_html
        check_friends(current_user, first_name, last_name)
      end
    rescue RBook::FacebookSession::RemoteException => e
      flash[:error] = "An exception occurred while trying to get friends from Facebook: #{e}"
    end
  end  

  private
  #check for and add people with matching names as friends of +user+
  def check_friends(user, first_name, last_name)
    friends = User.find :all, :conditions => {:first_name => first_name, :last_name => last_name}
    friends.each do |friend| 
      if not user.friends.exists? friend.id
        user.friends.concat friend
        friend.friends.concat user
      end
   end
  end
end
