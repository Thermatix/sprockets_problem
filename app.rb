require 'bundler/inline'
require_relative 'assets'

gemfile true do
	source 'https://rubygems.org'
	gem "sinatra", "1.4.6"
	gem "sprockets", "2.12.4"
	gem "sass", "3.4.13"
	gem "yui-compressor", "0.12.0"
	gem "opal", "~> 0.6"
	gem "react.rb", "~> 0.3"
	gem "puma", "2.11.2"
end

class App < Sinatra::Base

	enable :run
	set :sessions, true
	set :root, File.expand_path('.',File.dirname(__FILE__))
	set :threaded, true
	set :asset_root, 'assets'
	set :server, :puma
	Tilt.register Tilt::ERBTemplate, 'html.erb'
	include Assets

	get '/' do
		erb :index
	end
end