require 'sinatra'
require 'application'
require 'warden'

set :run, false
# set :environment, :production

use Rack::Session::Cookie
use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.faliure_app = Application
end

Application.run!
