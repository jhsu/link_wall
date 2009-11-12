require 'sinatra'
require 'warden'
require 'sinatra/activerecord'
require 'haml'
require 'sass'

Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.find(id) }

Warden::Manager.before_failure do |env,opts|
  # Sinatra is very sensitive to the request method
  # since authentication could fail on any type of method, we need
  # to set it for the failure app so it is routed to the correct block
  env['REQUEST_METHOD'] = "POST"
end

configure do
  if (ENV['DATABASE_URL'])
    set :database, ENV['DATABASE_URL']
  else
    set :database, "sqlite://database.db"
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'database.db')
    ActiveRecord::Base.logger = Logger.new("activerecord.log") # Somehow you need logging right?
  end
  set :views, File.dirname(__FILE__) + '/lib/views'
end

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |lib| require File.basename(lib, '.*') }

Warden::Strategies.add(:password) do
  def valid?
    params["username"] || params["password"]
  end

  def authenticate!
    u = User.authenticate(params["username"], params["password"])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end

class LinkWall < Sinatra::Base
  disable :run
  enable :sessions
  set :views, File.join(File.dirname(__FILE__), 'lib/views')
  enable :static
  set :public, File.join(File.dirname(__FILE__), 'public')

  helpers do
    def method_missing(method_name, *args, &block)
      method_str = method_name.to_s

      if method_str =~ /^_.+$/
        partial_name = method_str[/^_(.+)$/, 1]
        concat_partial partial_name
      elsif method_str =~ /^authenticate|logout/
        env['warden'].send(method_name, *args, &block)
      end
    end

    def concat_partial(partial_name)
      content = haml "_#{partial_name}".to_sym, :layout => false
      concat content
      nil
    end

    def warden
      env['warden']
    end
  end

  get '/' do
    users = User.all
    haml :root, :locals => { :users => users }
  end

  get '/home' do
    authenticate!
    haml :home
  end

  # Warden

  post '/unauthenticated/?' do
    status 401
    haml :login
  end

  get '/login/?' do
    haml :login
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
    sass :layout
  end

end
