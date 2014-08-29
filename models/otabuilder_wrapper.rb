require 'rubygems'
require 'require_relative'
require 'net/http'
require 'open-uri'

require_relative '../lib/plist_generator.rb'
require_relative '../lib/dropbox_upload.rb'
require_relative '../lib/ipa_search.rb'
require_relative '../lib/mail_parser.rb'
require_relative '../lib/mailer.rb'
require_relative '../lib/data_from_ipa.rb'

class OtabuilderWrapper<Jenkins::Tasks::Publisher
  
  include Jenkins::Model::DescribableNative
  
  display_name 'Upload Build and Mail OTA link'
  
  attr_accessor :ipa_path
  attr_accessor :bundle_identifier
  attr_accessor :bundle_version
  attr_accessor :title
  attr_accessor :db_dir
  attr_accessor :db_user
  attr_accessor :gmail_user
  attr_accessor :gmail_pass
  attr_accessor :reciever_mail_id
  attr_accessor :mail_body
  attr_accessor :mail_subject
  attr_accessor :reply_to
  attr_accessor :bcc

  def initialize(attrs)
    @ipa_path = attrs['ipa_path']
    @db_dir = attrs['db_dir']
    @db_user = attrs['db_user']
    @reciever_mail_id = attrs['reciever_mail_id']
    @mail_subject = attrs['mail_subject']
    @reply_to = attrs['reply_to']
    @mail_body  = attrs['mail_body']
    @bcc = attrs['bcc'] 
  end
  
  def needsToRunAfterFinalized
    return true
  end
  
  def prebuild(build,listner)
  end
  

  def perform(build,launcher,listner)
      
      #project informations
      workspace_path = build.native.getProject.getWorkspace() #get the workspace path
      
      listner.error @ipa_path + " ipa path"
      listner.error Dir.entries(@ipa_path)
      
      search_path = @ipa_path.nil? ? workspace_path : @ipa_path
      ipa_filepath = IPASearch::find_in search_path
      ipa_filename = File.basename ipa_filepath
      
      #build informations
      project_name = build.native.getProject.displayName
      build_number = build.native.getNumber()
      build_number = build_number.to_s
      
      ipa_file_data_obj = IPAFileData.new
      info_plist_path = ipa_file_data_obj.binary_plist_path_of ipa_filepath
      info_plist_contents = ipa_file_data_obj.contents_of_infoplist info_plist_path, ipa_filepath
      ipa_info_obj = IPA.new info_plist_contents
      
      #manifest information
      @bundle_identifier = ipa_info_obj.bundleidentifier
      @bundle_version = ipa_info_obj.bundleversion
      @title = ipa_info_obj.displayname
      
      #icon_filename = ipa_info_obj.icon
      #@icon_path = ipa_file_data_obj.path_to_icon_file_with_name icon_filename, ipa_filepath

      #upload information
      
      project = {
                  :name => project_name, 
                  :build_number => build_number
                }
      
      #uploading the ipa
      
      ipa_url = ''
      
      #begin
        ipa_url = DROPBOX::upload ipa_filepath, @db_dir + ipa_filename, @db_dir, listner
        ipa_url["?dl=0"] = ""
      #rescue
      # listner.error ipa_url + " failed upload"
      # build.halt
      #end
      
      #uploading the icon
      
     # icon_url =  ''
     # begin
      #  icon_url = DROPBOX::upload @icon_path, @db_dir + icon_filename, '/iOSBuilds'
     # rescue
     #  listner.error "Dropbox Connection Refused, check the Dropbox Settings"
     #  build.halt
     # end
      
      manifest_file = Manifest::create ipa_url, @bundle_identifier, @bundle_version, @title, File.dirname(ipa_filepath)
     
      manifest_url =  ''
      #begin
        manifest_url = DROPBOX::upload manifest_file, @db_dir + '/manifest.plist', '/iOSBuilds', listner
     # rescue
     #  listner.error manifest_url + "failed upload"
      # build.halt
      #end
     
      #Test this part is working 
      
      #If above works, delete the following parts
      
      manifest_filename = File.basename manifest_file
      itms_link = "itms-services://?action=download-manifest&url=#{manifest_url}"
      itms_link = itms_link.gsub /\s*/,''
      itms_link["?dl=0"] = ""
      
      listner.info itms_link
      listner.info @mail_body
      listner.info build_number
      listner.info project[:name]
      
      mail_body = @mail_body
     
      mail_body = MailParser::substitute_variables mail_body do
        [
          {
            :replace=>"{itms_link}",
            :with=>itms_link
          },
          {
            :replace=>"{build_number}",
            :with=>build_number
          },
          {
            :replace=>"{project}",
            :with=>project[:name]
          }
        ]
      end
      
      listner.info mail_body
      
      begin  
        file = File.open(@ipa_path + "/index.html", "w")
        file.write(mail_body) 
      rescue IOError => e
        #some error occur, dir not writable etc.
      ensure
        file.close unless file == nil
      end
      
      #mailing information
      mail_body = MailParser::get_html mail_body
      
      mail_subject = MailParser::substitute_variables @mail_subject do
        [
          {
            :replace=>"{build_number}",
            :with=>build_number
          },
          {
            :replace=>"{project}",
            :with=>project[:name]
          }
        ]
      end
      
      listner.info mail_subject

      mail = JenkinsMail.new
      
      listner.info mail
      listner.info @reciever_mail_id
      listner.info @sender_mail_id
      listner.info @reply_to
      listner.info @bcc
      
      mail.compose do 
        {
          :to =>  @reciever_mail_id,
          :from => @sender_mail_id,
          :subject =>  mail_subject,
          :html_body=> mail_body,
          :reply_to=> @reply_to,
          :bcc=> @bcc
        }
      end

      mail.send(listner)
  end
        
end
