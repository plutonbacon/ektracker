require 'rubygems'
require 'bundler/setup'

require 'haml'
require 'sinatra'

require_relative './constants'
require_relative './utils'
require_relative './models/init'

module EKTracker
  class App < Sinatra::Base

    get '/' do
      haml :index
    end

  end # class App
end # module EKTracker
