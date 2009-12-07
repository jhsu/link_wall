require 'sinatra/base'
require 'sinatra/activerecord'
require 'rack-flash'
require 'warden'
require 'will_paginate'
require 'haml'
require 'sass'
require 'httparty'
require 'net/http'
require 'digest/sha1'

Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.find(id) }

Warden::Manager.before_failure do |env,opts|
  # Sinatra is very sensitive to the request method
  # since authentication could fail on any type of method, we need
  # to set it for the failure app so it is routed to the correct block
  env['REQUEST_METHOD'] = "POST"
end

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |lib| require File.basename(lib, '.*') }

Warden::Strategies.add(:password) do
  def valid?
    params["username"] || params["password"]
  end

  def authenticate!
    u = User.authenticate(params["username"], params["password"])
    if u.nil?
      fail!("Could not log in")
    else
      success!(u)
    end
  end
end

class LinkWall < Sinatra::Base
  use Rack::Flash
  configure do
    disable :run
    enable :sessions
    set :views, File.join(File.dirname(__FILE__), 'lib/views')
    enable :static
    set :public, File.join(File.dirname(__FILE__), 'public')
    set :views, File.dirname(__FILE__) + '/lib/views'
    if (ENV['DATABASE_URL'])
      set :database, ENV['DATABASE_URL']
    else
      set :database, "sqlite://database.db"
      ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'database.db')
      ActiveRecord::Base.logger = Logger.new("activerecord.log") # Somehow you need logging right?
    end
  end

  helpers do
    def method_missing(method_name, *args, &block)
      method_str = method_name.to_s
      if method_str.match /^_.+$/
        options = {}
        options.merge!(args.first) unless args.empty?
        class_eval <<-RUBY
          def #{method_name}(options={})
            haml :#{method_name}, :locals => options, :layout => false
          end
RUBY
        send(method_name, options)
      elsif method_str =~ /^authenticate|logout/
        env['warden'].send(method_name, *args, &block)
      else
        super
      end
    end

    def host
      if request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/
        request.env['HTTP_X_FORWARDED_SERVER']
      else
        request.host
      end
    end

    def base_url
      scheme = request.scheme
      port = request.port
      url = "#{scheme}://#{host}"
      if scheme == "http" && port != 80 || scheme == "https" && port != 443
        url << ":#{port}"
      end
      url << "/"
    end

    def clippy(text, bgcolor='#FFFFFF')
      html = <<-EOF
        <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
                width="110"
                height="14"
                id="clippy" >
        <param name="movie" value="/flash/clippy.swf"/>
        <param name="allowScriptAccess" value="always" />
        <param name="quality" value="high" />
        <param name="scale" value="noscale" />
        <param NAME="FlashVars" value="text=#{text}">
        <param name="bgcolor" value="#{bgcolor}">
        <embed src="/flash/clippy.swf"
              width="110"
              height="14"
              name="clippy"
              quality="high"
              allowScriptAccess="always"
              type="application/x-shockwave-flash"
              pluginspage="http://www.macromedia.com/go/getflashplayer"
              FlashVars="text=#{text}"
              bgcolor="#{bgcolor}"
        />
        </object>
      EOF
    end

    def warden
      env['warden']
    end

    def current_user
      warden.user
    end

    def current_page
      params[:page].to_i + 1 || 0
    end

    def show_link(group)
      "/#{group.token}"
    end
  end

  get '/' do
    haml :root
  end

  get '/home' do
    authenticate!
    user = User.find(warden.user.id, :include => [:groups => :links])
    haml :home, :locals => {:user => user}
  end

  get '/links' do
    authenticate!
    @user = warden.user
    haml :links, :locals => {:user => @user}
  end

  post '/links' do
    authenticate!
    group = Link.find_or_create(:url => params[:url], :user_id => warden.user.id) unless params[:url].gsub(/\n/,'').blank?
    if group
      if request.xhr?
        _link_group(:group => group)
      else
        redirect show_link(group)
      end
    else
      if request.xhr?
      else
        flash[:error] = "Unable to add link"
        redirect '/links/new'
      end
    end
  end

  get '/links/show/:token' do
    group = Group.find_by_token(params[:token], :include => {:links => :clicks})
    haml :_link_group, :locals => {:group => group}
  end

  post '/links/:id/clicked' do
    if params[:id] && link = Link.first(:conditions => ["id = ?", params[:id].to_i], :include => :clicks)
      link.clicked(env['REMOTE_ADDR'])
      if request.xhr?
        "#{link.clicks.count}"
      else
        redirect link.url
      end
    end
  end

  # Warden

  post '/unauthenticated/?' do
    status 401
    haml :login
  end

  get '/login/?' do
    haml :login
  end

  get '/signup' do
    haml :signup
  end

  post '/signup' do
    if params[:username] && params[:password] && params[:password_confirmation]
      user = User.new(params)
      # create and create session
      redirect '/home'
    else
      redirect '/signup'
    end
  end

  post '/login/?' do
    authenticate!
    redirect "/home"
  end

  get '/logout/?' do
    warden.logout
    redirect '/'
  end

  # Sass

  get '/layout.css' do
    content_type('text/css')
    sass :layout
  end

  # Shortened
  get '/shorten' do
    if params[:url] && params[:user] && user = User.find_by_username(params[:user])
      group = Link.find_or_create(:url => params[:url], :user => user)
      haml "#{base_url + group.token}", :layout => false
    end
  end

  get '/:token' do
    if group = Group.find_by_token(params[:token], :include => {:links => :clicks})
      group.viewed
      clicks = group.clicks_by_day
      haml :show, :locals => {:group => group, :clicks => clicks}
    else
      haml :not_found
    end
  end

end
