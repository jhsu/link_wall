require 'sinatra'
require 'sinatra/sequel'
# require 'sinatra/sassacache'
require 'haml'
require 'sass'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib/models")
Dir.glob("#{File.dirname(__FILE__)}/lib/models/*.rb") { |lib| require File.basename(lib, '.*') }

class Application < Sinatra::Base
  configure do
    if (ENV['DATABASE_URL'])
      set :database, ENV['DATABASE_URL']
    else
      set :database, "sqlite://database.db"
    end
    set :views, File.dirname(__FILE__) + '/lib/views'
  end

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
    haml :home
  end

  # Session

  get '/login/?' do
    haml :login
  end

  post '/login/?' do
    env['warden'].authenticate!
    redirect '/home'
  end

  get '/logout/?' do
    env['warden'].logout
    redirect '/'
  end

  # Sass

  get '/layout.css' do
    sass :layout
  end
end
