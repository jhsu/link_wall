require 'application'

use Rack::Session::Cookie
use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = LinkWall
end

run LinkWall
