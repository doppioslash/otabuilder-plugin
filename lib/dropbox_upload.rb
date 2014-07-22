#Claudia Doppioslash @Starship 2014
#Dropbox Module
#using dropbox as ipa host

require 'rubygems'
require 'dropbox_sdk'

module DROPBOX
  APP_KEY = '6r0pxf0xwkbwfxi'
  APP_SECRET = 't16ufvprm1qb1lb'
  TOKEN = '775lpXasKnIAAAAAAAB3c2yq2QKsvYX2Rre044VVECQ7PgIRl98CHZvqewIKrAd1'
  
  def self.upload(local_path, remote_path, remote_dir, listner)
    client = DropboxClient.new(TOKEN)
    listner.warning "linked account:", client.account_info().inspect
    
    file = open(local_path)
    
    response = client.put_file(remote_path, file)
    listner.warning "uploaded:", response.inspect
    
    root_metadata = client.metadata(remote_dir)
    listner.warning "metadata:", root_metadata.inspect
    
    contents, metadata = client.get_file_and_metadata(remote_path)
    open('magnum-opus.txt', 'w') {|f| f.puts contents }
    
    shareLink = client.shares(remote_path, 0)['url']
    listner.warning "share link: ", shareLink
    shareLink ['www.dropbox.com'] = 'dl.dropboxusercontent.com'
    listner.warning "direct link: ", shareLink
    return shareLink
  
  end
end