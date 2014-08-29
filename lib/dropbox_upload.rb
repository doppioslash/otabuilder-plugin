<<<<<<< HEAD
#Claudia Doppioslash @Starship 2014
#Dropbox Module
#using dropbox as ipa host

require 'rubygems'
require 'dropbox_sdk'

module DROPBOX
  
  APP_KEY = '...'
  APP_SECRET = '...'
  TOKEN = '...'
    
  def self.upload(local_path, remote_path, remote_dir, listner)
    
    listner.error "In dropbox upload " + TOKEN
    client = DropboxClient.new(TOKEN)
    
    listner.error local_path
    listner.error remote_path
    listner.error remote_dir
    listner.error client
    listner.error "linked account:" + client.account_info().inspect
    
    file = open(local_path)
    response = client.put_file(remote_path, file, true)
    listner.error "uploaded:" + response.inspect
    root_metadata = client.metadata(remote_dir)
    listner.error "metadata:" + root_metadata.inspect
    contents, metadata = client.get_file_and_metadata(remote_path)
    shareLink = client.shares(remote_path, 0)['url']
    listner.error "share link: " + shareLink
    shareLink ['www.dropbox.com'] = 'dl.dropboxusercontent.com'
    listner.error "direct link: " + shareLink
    return shareLink
  
  end
end