#Jesly Varghese 2012
#Mailer class
#This class sends a mail to the specified set of people.

require "rubygems"
require "require_relative"

require_relative "Mailer/smtp_mail.rb"
require_relative "Mailer/mail.rb"

class JenkinsMail<NotificationMail
  
  def compose
    mail_parameters = yield
    
    mail_parameters.each do  |parameter,value|
      self.instance_variable_set("@#{parameter}",value)
    end
  end
  
end