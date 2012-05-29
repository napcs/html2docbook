require 'rubygems'
require 'bundler'

Bundler.require

require './app'

set :run,         false

run Sinatra::Application