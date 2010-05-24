class ProfileController < ApplicationController
  skip_filter :authenticate, :only => :register

  def index
    redirect_to :action => 'show'
  end

  #show a user's profile
  def show
    if params[:id] != nil
      @user = User.find(params[:id])
    else
      @user = User.find session[:user]
    end
    @friends = @user.friends
  end

  #register as a new user
  def register
    if (params[:user] != nil)
      @user = User.new(params[:user])
      if @user.save
        session[:user] = @user.id
        session[:username] = @user.username
        flash[:notice] = 'Your account is now created!'
        redirect_to :action => 'show'
        return
      end
    else
      @user = User.new()
    end
    @colleges = College.find(:all, :order => 'name ASC')
    @majors = Major.find(:all, :order => 'name ASC')
  end

  #edit an existing user's profile
  def edit
    @user = User.find session[:user]
    if params[:user]
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Your changes have been successfully saved.'
        redirect_to :action => 'show', :id => @user
        return
      end
    end

    @colleges = College.find(:all, :order => 'name ASC')
    @majors = Major.find(:all, :order => 'name ASC')
  end
  
  #remove the logged in user from the system
  def destroy
    current_user = User.find session[:user]
    current_user.destroy
    redirect_to :controller => 'login', :action => 'logout'
  end
end
