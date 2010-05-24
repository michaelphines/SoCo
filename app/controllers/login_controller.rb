class LoginController < ApplicationController
  skip_filter :authenticate
  
  #prompt for username and password
  def index
    if session[:user]
      redirect_to :controller => 'profile', :action => 'show'
    end
  end
  
  #attempt to log in user
  def validate
    @user = User.authenticate(params[:user], params[:pass])
    if @user != nil
      session[:user] = @user.id
      session[:username] = @user.username
      redirect_to :controller => 'profile'
    else
      flash[:error] = "Invalid user name or password."
      redirect_to :action => 'index'
    end
  end
  
  #log out user
  def logout
    reset_session
    flash[:alert] = "Logged out" 
    redirect_to :action => "index" 
  end
end
