#!/usr/bin/env ruby

require "rubygems"
require "lib/facebook_desktop_session.rb"

API_KEY = "PUT YOUR KEY HERE"
API_SECRET = "PUT YOUR SECRET HERE"

# create the Facebook session object
desktopSession = RBook::FacebookDesktopSession.new(API_KEY, API_SECRET)

# since this is a Desktop application, we need an Auth Token
token = desktopSession.get_auth_token

# now, using this token we can make the URL for users to vist
print "Please log in at the following URL (copy and paste into your browser):\n"
print desktopSession.get_login_url(token)
print "\nPlease press enter after you are finished logging in.\n"
gets

# now we have a valid token, so we can initialize the Facebook session object with that token
print "The token #{token} is now valid to use.\n"
desktopSession.init_with_token(token)

# ...and make some calls
myUserId = desktopSession.session_uid
xml = desktopSession.users_getInfo({
                        :uids => [myUserId],
                        :fields =>["first_name", "last_name", "birthday"]
                      })

firstname = xml.at("//first_name").inner_html.to_s
lastname = xml.at("//last_name").inner_html.to_s
birthday = xml.at("//birthday").inner_html.to_s

print "Your name is #{firstname} #{lastname} and your were born on #{birthday}\n\n"

