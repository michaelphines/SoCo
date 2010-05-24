require File.dirname(__FILE__) + '/../test_helper'

class FriendMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_see_my_schedule
    #@expected.subject = 'FriendMailer#see_my_schedule'
    #@expected.body    = read_fixture('see_my_schedule')
    #@expected.date    = Time.now

    #Hackish
    body =  " Kathleen Reilly, would you like to join Chris Horneck in any of these classes? CS 428\n\n "\
            << "Use your email address (reillyke@gmail.com) to log in if you are not "\
            << "already registered with soco. http://localhost:3000/login"
            
    subject =  "Take a look at Chris Horneck's classes for the following semester"       
           
    response = FriendMailer.create_see_my_schedule("Chris Horneck", "chorneck@gmail.com", "Kathleen Reilly", "reillyke@gmail.com", "CS 428")
    assert_equal body, response.body
    assert_equal subject, response.subject
    assert_equal "reillyke@gmail.com", response.to[0]
    
    #(my_name, my_email, friend_name, friend_email, classes_shared)
    #assert_equal @expected.encoded, FriendMailer.create_see_my_schedule(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/friend_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
