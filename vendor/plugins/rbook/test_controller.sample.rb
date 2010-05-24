class TestController < ApplicationController
  
  def facebook_login
    
    # create a FacebookWebSession using our own API key and secret
    session[:fbsession] = FacebookWebSession.new(YOUR_API_KEY, YOUR_API_SECRET)
    
    # redirect the user to Facebook to log in
    redirect_to session[:fbsession].get_login_url
    
  end
  
  
  # NOTE: you must have your developer account configured to redirect to this URL on your site
  def facebook_callback
    
    begin
      
      # use the token that Facebook gave us to initialize our FacebookWebSession
      session[:fbsession].token = params[:auth_token]
      
      # the current users Facebook id is stored in the session_uid member
      currentUserId = session[:fbsession].session_uid
      
      # lets make a sample call to the API...how about users.getInfo?
      # We'll get information on the current user id.
      xml = session[:fbsession].users_getInfo({
                        :uids => [currentUserId],
                        :fields =>["first_name", "last_name", "birthday"]
                      })

      firstname = xml.at("//first_name").inner_html.to_s
      lastname = xml.at("//last_name").inner_html.to_s
      birthday = xml.at("//birthday").inner_html.to_s
      
      # success!
      render_text "Successfully Authenticated, your name is #{firstname} #{lastname} and you were born on #{birthday}"
      
    rescue RBook::FacebookSession::RemoteException => e
      
      # failure, either during authentication or when we made that users.getInfo call
      render_text "An exception occurred while trying to communicate with Facebook: #{e}"
      
    end
  end 
  
end
