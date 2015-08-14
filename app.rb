require 'bundler/inline'

gemfile false do
	source 'https://rubygems.org'
	gem "sinatra", "1.4.6"
	gem "sprockets", "~> 3.3"
	gem "sass", "3.4.13"
	gem "yui-compressor", "0.12.0"
	gem "opal", "~> 0.8"
	gem "react.rb", "0.3.0.13"
	gem "puma", "2.11.2"
	gem "tilt", "~> 2.0"
	gem "sprockets-helpers", "~> 1.2"
end

require 'sinatra/base'
require_relative 'assets'

class App < Sinatra::Base

	enable :run
	set :sessions, true
	set :root, File.expand_path('.',File.dirname(__FILE__))
	set :threaded, true
	# set :assets_prefix, 'assets'
	set :server, :puma
	Tilt.register Tilt::ERBTemplate, 'html.erb'
	# include Assets

	get '/' do
		erb :index
	end

	include Assets
	


end