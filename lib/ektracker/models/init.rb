require 'rubygems'
require 'bundler/setup'

require 'sequel'

dsn = ENV['EKTRACKER_DB_URL'] || 'postgres://ektracker:test@localhost/ektracker'

DB = Sequel.connect(dsn)

$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative './artifacts'

Sequel.extension :core_extensions

Sequel::Model.plugin :json_serializer
Artifact.plugin :json_serializer

Sequel::Model.plugin :timestamps
Artifact.plugin :timestamps
