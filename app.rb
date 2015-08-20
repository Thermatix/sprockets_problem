require 'bundler/inline'

gemfile false do #change this to true to install gems
	source 'https://rubygems.org'
	gem "sinatra", "1.4.6"
	gem "sprockets", "~> 3.3"
	gem "sass", "3.4.13"
	gem "yui-compressor", "0.12.0"
	gem 'opal-react', git: "https://github.com/catprintlabs/react.rb.git", :branch => 'isomorphic-methods-support'
	gem "puma", "2.11.2"
	gem "tilt", "~> 2.0"
	gem "sprockets-helpers", "~> 1.2"
    gem "opal", "0.9.0.dev"
    gem "opal-jquery", "~> 0.4"
end

require 'sinatra/base'
require_relative 'assets'

class App < Sinatra::Base

	enable :run
	set :sessions, true
	set :root, File.expand_path('.',File.dirname(__FILE__))
	set :threaded, true
	set :server, :puma
	set :opal_libs, %w{opal-react opal-jquery}

	get '/' do
		erb :index
	end

	include Assets
	


end