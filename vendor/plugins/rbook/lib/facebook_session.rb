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

require "digest/md5"
require "net/https"
require "cgi"
require "hpricot"

module RBook

API_SERVER_BASE_URL      = "api.facebook.com"
LOGIN_SERVER_BASE_URL    = "www.facebook.com"
API_SERVER_PATH          = "/restserver.php"
LOGIN_SERVER_PATH        = "/login.php"

class FacebookSession
  
  attr_reader :session_uid, :session_key, :session_secret
  attr_reader :last_call_was_successful, :last_error
  attr_writer :suppress_exceptions
  
  # SECTION: Exceptions
    
  class RemoteException < Exception; end
  
  # SECTION: Public Methods  
  
  # Function: initialize
  #   Constructs a FacebookSession
  #
  # Parameters:
  #   api_key                       - your API key
  #   api_secret                    - your API secret
  #   suppress_exceptions           - boolean, set to true if you don't want exceptions to be thrown (defaults to false)
  def initialize(api_key, api_secret, suppress_exceptions = false)
    
    # required parameters
    @api_key = api_key
    @api_secret = api_secret
    
    # calculated parameters
    @api_server_base_url = API_SERVER_BASE_URL
    @api_server_path = API_SERVER_PATH
        
    # optional parameters
    @suppress_exceptions = suppress_exceptions
    
    # initialize internal state
    @last_call_was_successful = true
    @last_error = nil
    
    # virtual members (subclasses will set these)
    @session_uid = nil
    @session_key = nil
    
  end
  
  def token=(auth_token)
    init_with_token(auth_token)
  end
  
  protected
  
  # SECTION: Protected Abstract Interface
  
  def get_secret(params)
    raise Exception
  end
  
  def init_with_token(auth_token)
    raise Exception
  end
  
  # SECTION: Protected Methods
  
  attr_reader :session_key
  attr_writer :session_key, :session_uid
  
  # Function: method_missing
  #   This allows *any* Facebook method to be called, using the Ruby
  #   mechanism for responding to unimplemented methods.  Basically,
  #   this converts a call to "auth_getSession" to "auth.getSession"
  #   and does the proper API call using the parameter hash given.
  def method_missing(methodSymbol, *params)
    methodString = methodSymbol.to_s.gsub!("_", ".")
    # TODO: check here for valid method names
    call_method(methodString, params.first)
  end
  
  # Function: call_method
  #   Sets up the necessary parameters to make the POST request to the server
  #
  # Parameters:
  #   method              - i.e. "users.getInfo"
  #   params              - hash of key,value pairs for the parameters to this method
  #   use_ssl             - set to true if the call will be made over SSL
  def call_method(method, params={}, use_ssl=false)
    
    # set up params hash
    params = params ||= {}
    params[:method] = "facebook.#{method}"
    params[:api_key] = @api_key
    params[:v] = "1.0"
    
    if (method != "auth.getSession" and method != "auth.createToken")
      params[:session_key] = @session_key
      params[:call_id] = Time.now.to_f.to_s
    end
    
    # convert arrays to comma-separated lists
    params.each{|k,v| params[k] = v.join(",") if v.is_a?(Array)}
    
    # set up the param_signature value in the params
    params[:sig] = param_signature(params)
    
    # prepare internal state
    @last_call_was_successful = true
    @last_error = nil
    
    # do the request
    xmlstring = post_request(@api_server_base_url, @api_server_path, method, params, use_ssl)
    xml = Hpricot(xmlstring)

    # error checking    
    if xml.at("error_response")
      @last_call_was_successful = false
      code = xml.at("error_code").inner_html
      msg = xml.at("error_msg").inner_html
      @last_error = "ERROR #{code}: #{msg}"
      raise RemoteException, @last_error unless @suppress_exceptions == true
      return nil
    end
    
    return xml
  end
  
  # SECTION: Private Methods
  
  private
  
  # Function: post_request
  #   Does a post to the given server/path, using the params as formdata
  #
  # Parameters:
  #   api_server_base_url         - i.e. "api.facebook.com"
  #   api_server_path             - i.e. "/restserver.php"
  #   method                      - i.e. "facebook.users.getInfo"
  #   params                      - hash of key/value pairs that get sent as form data to the server
  #   use_ssl                     - set to true if you want to use SSL for this request
  def post_request(api_server_base_url, api_server_path, method, params, use_ssl)
    
    # get a server handle
    port = (use_ssl == true) ? 443 : 80
    http_server = Net::HTTP.new(@api_server_base_url, port)
    http_server.use_ssl = use_ssl
    
    # build a request
    http_request = Net::HTTP::Post.new(@api_server_path)
    http_request.form_data = params
    response = http_server.start{|http| http.request(http_request)}.body
    
    # return the text of the body
    return response
    
  end
  
  # Function: param_signature
  #   Generates a param_signature for a call to the API, per the spec on Facebook
  #   see: <http://developers.facebook.com/documentation.php?v=1.0&doc=auth>
  def param_signature(params)
    
    args = []
    params.each do |k,v|
      args << "#{k}=#{v}"
    end
    sorted_array = args.sort
    request_str = sorted_array.join("")
    param_signature = Digest::MD5.hexdigest("#{request_str}#{get_secret(params)}") # uses Template method get_secret
    return param_signature
    
  end

end

end
