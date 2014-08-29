#Jesly Varghese 2012
#Mail Class
#This class sends a mail to the specified set of people.

#this could have been done in two ways, either use native java methods or go for rb methods
#i choose the latter

class NotificationMail<SMTP
	
  attr_accessor :to,
              	:cc,
              	:bcc,
              	:from,
              	:body,
              	:html_body,
              	:subject,
              	:charset,
              	:text_part_charset,
              	:attachments,
              	:headers,
              	:sender,
              	:reply_to
  
	
  def intialize
		#give values to all those subtle variables needed here.
		@charset = 'UTF-8'
		@text_part_charset = 'UTF-8'
		@headers = "MIME-version: 1.0;
					Content-Type: multipart/related;
					boundary=Boundary;type=text/html"
	end

	def send(listner)
		listner.info Pony
		Pony.mail({
				:to => @to,
				:cc => @cc,
				:bcc=> @bcc,

				:from=> @from,

				:body => @body,
				:html_body => @html_body,

				:subject => @subject,

				:charset => @charset,
				:text_part_charset => @text_part_charset,

				:attachments => @attachments,

				:headers => { 'Content-Type' => 'text/html' },
				:sender => @sender,
				:reply_to => @reply_to,

				:via =>:smtp,
				:via_options =>{
					:address => @server,
					:port    => @port,
					:openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE,
					:enable_starttls_auto   => false,
					:user_name => @user_name,
					:password => @password,
					:authentication => :login

				}
			})
	end
  
end



