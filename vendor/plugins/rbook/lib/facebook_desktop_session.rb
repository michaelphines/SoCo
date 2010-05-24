# Copyright (c) 2007, Matt Pizzimenti (www.livelearncode.com)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# Some code was inspired by techniques used in Alpha Chen's old client.
# Some code was ported from the official PHP5 client.
#

require File.dirname(__FILE__) + "/facebook_session"

module RBook

class FacebookDesktopSession < FacebookSession
  
  # Function: get_login_url
  #   Gets the authentication URL
  #
  # Parameters:
  #   auth_token            - the string auth_token received from getToken
  #   options.next          - the page to redirect to after login
  #   options.popup         - boolean, whether or not to use the popup style (defaults to true)
  #   options.skipcookie    - boolean, whether to force new Facebook login (defaults to false)
  def get_login_url(auth_token, options={})
    # options
    path_next = options[:next] ||= nil
    popup = (options[:popup] == nil) ? true : false
    skipcookie = (options[:skipcookie] == nil) ? false : true
    
    # get some extra portions of the URL
    optionalNext = (path_next == nil) ? "" : "&next=#{CGI.escape(path_next.to_s)}"
    optionalPopup = (popup == true) ? "&popup=true" : ""
    optionalSkipCookie = (skipcookie == true) ? "&skipcookie=true" : ""
    
    # build and return URL
    return "http://#{LOGIN_SERVER_BASE_URL}#{LOGIN_SERVER_PATH}?v=1.0&api_key=#{@api_key}&auth_token=#{auth_token}#{optionalPopup}#{optionalNext}#{optionalSkipCookie}"
  end
  
  
  # Function: initialize
  #   Constructs a FacebookSession
  #
  # Parameters:
  #   api_key                       - your API key
  #   api_secret                    - your API secret
  #   desktop                       - boolean, whether this is a desktop client or not (defaults to false)
  #   options.suppress_exceptions   - boolean, set to true if you don't want exceptions to be thrown (defaults to false)
  def initialize(api_key, api_secret, suppress_exceptions = false)
    super(api_key, api_secret, suppress_exceptions)    
  end
  
  # Function: auth_createToken
  #   Returns a string auth_token
  def get_auth_token
    result = call_method("auth.createToken", {})
    result = result.at("auth_createtoken_response").inner_html.to_s ||= result.at("auth_createToken_response").inner_html.to_s
    return result
  end
  
  
  # Function: init_with_token
  #   Gets the session information available after current user logs in.
  # 
  # Parameters:
  #   auth_token    - string token returned by auth_createToken (see: <auth_createToken>)
  def init_with_token(auth_token)
    result = call_method("auth.getSession", {:auth_token => auth_token}, true)
    if result != nil
      @session_uid = result.at("uid").inner_html
      @session_key = result.at("session_key").inner_html
      @session_secret = result.at("secret").inner_html
    end
    return result
  end
  
  # Function: get_secret
  #   Template method, used by super::signature to generate a signature
  def get_secret(params)
    
    if ( params[:method] != "facebook.auth.getSession" and params[:method] != "facebook.auth.createToken")
      return @session_secret
    else
      return @api_secret
    end
    
  end
  
end



end
    
