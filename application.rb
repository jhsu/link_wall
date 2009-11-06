require 'sinatra'
require 'sinatra/sequel'
require 'warden'
require 'haml'
require 'sass'

configure do
  if (ENV['DATABASE_URL'])
    set :database, ENV['DATABASE_URL']
  else
    set :database, "sqlite://database.db"
  end
  set :views, File.dirname(__FILE__) + '/lib/views'
end

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |lib| require File.basename(lib, '.*') }

Warden::Strategies.add(:password) do
  def valid?
    params[:username] || params[:password]
  end

  def authenticate!
    u = User.authenticate(params[:username], params[:password])
    # u.nil? ? fail!("Could not log in") : success!(u)
    success!(true)
  end
end

class LinkWall < Sinatra::Base
  disable :run
  set :views, File.join(File.dirname(__FILE__), 'lib/views')

# migration "create users" do
#   database.create_table :users do
#     primary_key :id
#     string      :username, :null => false, :unique => true
#     string      :password, :null => false

#     timestamp   :created_at, :null => false
#   end
# end

  helpers do
  end

  get '/' do
    haml :root
  end

  get '/home' do
    env['warden'].authenticate!
    haml :home
  end

  # Session

  get '/login' do
    haml :login
  end

  post '/login' do
    env['warden'].authenticate!
    redirect '/home'
  end

  get '/logout' do
    env['warden'].logout
    redirect '/'
  end


  # Warden

  post '/unauthenticated' do
    redirect '/login'
  end

  get '/unauthenticated' do
    redirect '/login'
  end

  # Sass

  get '/layout.css' do
    sass :layout
  end
end
