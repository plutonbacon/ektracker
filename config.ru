$stdout.sync = true
require_relative './lib/ektracker/app'

run Rack::URLMap.new('/' => EKTracker::App)
