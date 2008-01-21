#
# An integrated web server for hosting / sharing snips
#
# Basically, a front-end for a _local_ repository, so it can be used _remotely_
#
# Also contains utility methods for creating / running your own snip server(s)
#
class Snip::Server
  attr_accessor :repo, :app, :adapter, :user_file

  class User
    attr_accessor :name, :email, :hash, :salt
    def initialize attrs
      attrs.each { |k,v| instance_variable_set "@#{k}", v }
    end
  end

  def initialize repo_location, user_file = '~/.snip-server-users.yaml'
    @repo = Snip::Repo.new repo_location
    raise "what in the world do you think you're doing?  i only serve local repos" unless @repo.local?
    self.user_file = user_file

    require 'rack'
    require 'snips/snip_server'
    SnipServer::Communicator.repo = @repo
    
    @app     = SnipServer
    @adapter = Rack::Adapter::Camping.new SnipServer
  end

=begin
>> server = Snip::Server.new '~/temp/some_snips'
>> data = server.get_post_data 'remi', 'remi@remitaylor.com', 'PASSWORD'
>> require 'net/http'; require 'uri'; res = Net::HTTP.post_form(URI.parse('http://localhost:8080/signup'),data); res.body
>> require 'net/http'; require 'uri'; res = Net::HTTP.post_form(URI.parse('http://remi:PASSWORD@localhost:8080/some-file.1.rb'),{ 'snip' => "# Description: my snip!\nputs 'hello from my posted snip'" }); res.body
=end
  def init_user_file
    require 'yaml'
    user_file = File.expand_path self.user_file
    write_to_user_file( {}.to_yaml ) unless File.file? user_file
  end
  def write_to_user_file yaml
    user_file = File.expand_path self.user_file
    File.open( user_file, 'w' ){ |f| f << yaml }
  end
  def get_users
    init_user_file
    user_file = File.expand_path self.user_file
    yaml = YAML::load File.read( user_file )
  end
  def save_user user
    init_user_file
    users = get_users
    unless users.keys.include?user.name.strip
      users[user.name.strip] = user
      write_to_user_file users.to_yaml
      true
    else
      false # user already exists!
    end
  end
  def authenticate_user name, password
    users = get_users
    user  = users[name.strip]
    return false unless user
    return user.hash == Snip::Server.get_password_hash( password, user.salt )
  end
  def self.get_hash text
    require 'digest/sha1'
    Digest::SHA1.hexdigest text
  end
  def self.get_password_hash password, salt
    get_hash salt + password + salt
  end

  def self.get_post_data name, email, password
    post_vars = { 'name' => name, 'email' => email }
    salt = self.get_hash Time.now.to_s
    hash = self.get_password_hash password, salt
    post_vars.salt = salt
    post_vars.hash = hash
    post_vars
  end
  def reload_repo
    self.repo.reload
  end

  def call env
    request = Rack::Request.new env
    
    # if GET or POST to /filename
    filename = request.env.PATH_INFO.sub(/^\//,'')
    if filename[Snip::file_regex]
      if request.env.REQUEST_METHOD == 'GET'

        # return file    
        return Rack::File.new( @repo.location  ).call( env )

      elsif request.env.REQUEST_METHOD == 'POST'

        # authenticate user and create file, if it doesn't exist
        filepath = File.join( self.repo.location, filename )
        unless File.file? filepath and request.params['snip'] and not request.params['snip'].strip.empty?
          protected_section = lambda { |env|
            begin
              File.open( filepath, 'w' ){ |f| f << request.params['snip']  }
              reload_repo # so it shows up
              [200, {}, "Success!"] 
            rescue Exception => ex
              [200, {}, "Snip POST failed. ... #{ex}"] 
            end
          }
          authenticated_app = Rack::Auth::Basic.new( protected_section ) do |name,pass|
            authenticate_user name, pass
          end
          return authenticated_app.call( env )

        else
          [200, {}, "Snip POST failed."]
        end

      end
    
    elsif request.env.PATH_INFO == '/signup' and request.env.REQUEST_METHOD == 'POST'
      %w( name email salt hash ).each { |param|
        if request.params[param].nil? or request.params[param].strip.empty?
          return [200, {}, "You didn't provide all necessary parameters."] 
        end
      }
      user = User.new request.params
      saved = save_user user
      body = (saved) ? "New User Created: #{user.name}" : "user not created." 
      [ 200, {}, body ]

    # else, return a call to the normal app
    else
      @adapter.call env
    
    end
  end

  # basically for testing - for now
  def run
    require 'thin'
    Rack::Handler::Thin.run self
  end

  def sha1_javascript
    # thanks to:    Paul Andrew Johnston (http://pajhome.org.uk)
    # original url: http://pajhome.org.uk/crypt/md5/index.html
    # crunched by:  http://wbic16.xedoloh.com/cruncher.html
    #
    # usage: hex_sha1('string'); == require 'digest/sha1'; Digest::SHA1.hexdigest('string);
    #
    <<javascript_here
var hexcase=0;var b64pad="";var chrsz=8;function hex_sha1(s){return binb2hex(core_sha1(str2binb(s),s.length*chrsz));}function b64_sha1(s){return binb2b64(core_sha1(str2binb(s),s.length*chrsz));}function str_sha1(s){return binb2str(core_sha1(str2binb(s),s.length*chrsz));}function hex_hmac_sha1(key,data){return binb2hex(core_hmac_sha1(key,data));}function b64_hmac_sha1(key,data){return binb2b64(core_hmac_sha1(key,data));}function str_hmac_sha1(key,data){return binb2str(core_hmac_sha1(key,data));}function sha1_vm_test(){return hex_sha1("abc")=="a9993e364706816aba3e25717850c26c9cd0d89d";}function core_sha1(x,len){x[len>>5]|=0x80<<(24-len%32);x[((len+64>>9)<<4)+15]=len;var w=Array(80);var a=1732584193;var b=-271733879;var c=-1732584194;var d=271733878;var e=-1009589776;for(var i=0;i<x.length;i+=16){var olda=a;var oldb=b;var oldc=c;var oldd=d;var olde=e;for(var j=0;j<80;j++){if(j<16)w[j]=x[i+j];else w[j]=rol(w[j-3]^ w[j-8]^ w[j-14]^ w[j-16],1);var t=safe_add(safe_add(rol(a,5),sha1_ft(j,b,c,d)),safe_add(safe_add(e,w[j]),sha1_kt(j)));e=d;d=c;c=rol(b,30);b=a;a=t;}a=safe_add(a,olda);b=safe_add(b,oldb);c=safe_add(c,oldc);d=safe_add(d,oldd);e=safe_add(e,olde);}return Array(a,b,c,d,e);}function sha1_ft(t,b,c,d){if(t<20)return(b&c)|((~b)&d);if(t<40)return b ^ c ^ d;if(t<60)return(b&c)|(b&d)|(c&d);return b ^ c ^ d;}function sha1_kt(t){return(t<20)?1518500249:(t<40)?1859775393:(t<60)?-1894007588:-899497514;}function core_hmac_sha1(key,data){var bkey=str2binb(key);if(bkey.length>16)bkey=core_sha1(bkey,key.length*chrsz);var ipad=Array(16),opad=Array(16);for(var i=0;i<16;i++){ipad[i]=bkey[i]^ 0x36363636;opad[i]=bkey[i]^ 0x5C5C5C5C;}var hash=core_sha1(ipad.concat(str2binb(data)),512+data.length*chrsz);return core_sha1(opad.concat(hash),512+160);}function safe_add(x,y){var lsw=(x&0xFFFF)+(y&0xFFFF);var msw=(x>>16)+(y>>16)+(lsw>>16);return(msw<<16)|(lsw&0xFFFF);}function rol(num,cnt){return(num<<cnt)|(num>>>(32-cnt));}function str2binb(str){var bin=Array();var mask=(1<<chrsz)-1;for(var i=0;i<str.length*chrsz;i+=chrsz)bin[i>>5]|=(str.charCodeAt(i/chrsz)&mask)<<(32-chrsz-i%32);return bin;}function binb2str(bin){var str="";var mask=(1<<chrsz)-1;for(var i=0;i<bin.length*32;i+=chrsz)str+=String.fromCharCode((bin[i>>5]>>>(32-chrsz-i%32))&mask);return str;}function binb2hex(binarray){var hex_tab=hexcase?"0123456789ABCDEF":"0123456789abcdef";var str="";for(var i=0;i<binarray.length*4;i++){str+=hex_tab.charAt((binarray[i>>2]>>((3-i%4)*8+4))&0xF)+hex_tab.charAt((binarray[i>>2]>>((3-i%4)*8))&0xF);}return str;}function binb2b64(binarray){var tab="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";var str="";for(var i=0;i<binarray.length*4;i+=3){var triplet=(((binarray[i>>2]>>8*(3-i%4))&0xFF)<<16)|(((binarray[i+1>>2]>>8*(3-(i+1)%4))&0xFF)<<8)|((binarray[i+2>>2]>>8*(3-(i+2)%4))&0xFF);for(var j=0;j<4;j++){if(i*8+j*6>binarray.length*32)str+=b64pad;else str+=tab.charAt((triplet>>6*(3-j))&0x3F);}}return str;}
javascript_here
  end

end
