require "yui/compressor"
require "sass"
require 'sprockets'
require 'sprockets-helpers'
require 'opal'


module Assets
		
	Opal = ::Opal
	Sprockets = ::Sprockets
	

	class << self
		attr_reader :get_asset
		def defaults
			{
				root: Dir.pwd,
				prefix: 'assets',
				asset_folders: %w{javascripts stylesheets font images},
				public_path: -> {"#{settings.root}/public" },
				asset_folder: -> {"#{settings.root}/#{settings.prefix}" },
				digest: false,
				opal_libs: [],
				sprockets: -> { 
					Sprockets::Environment.new do |env|
						#register opal with sprockets
						# env.register_engine '.opal', Opal::Processor	

						#require opal libraries to load path
						settings.opal_libs.each do |lib|
							puts "require opal lib #{lib}"
							require lib
						end

						Opal.paths.each {|p|env.append_path p}
						
						settings.asset_folders.each do |folder|
							env.append_path "#{settings.asset_folder}/#{folder}"
						end
						
						#set up asset root folder
						env.append_path settings.asset_folder
						#set up compressers and pre-proccessors
						env.js_compressor = YUI::JavaScriptCompressor.new unless ENV['RACK_ENV'] != 'production'
						env.css_compressor = :sass
					end
				}
			}
		end

		def find_css_path asset_folders
			%w{css stylesheets}.each do |folder|
				break folder if asset_folders.include? folder
			end
		end
	end

	@get_asset = Proc.new do |file_name,extention|
		content_type mime_types[extention]
		settings.sprockets["#{file_name}#{extention}"]
	end

	def mime_types 
		{
			".css" => "text/css",
			".js" => "application/javascript"
		}
	end
	

	def self.included base
		base.class_exec(self) do |assets|

			#configure opal
			Opal::Config.config.each do |c_option,default|
			    if settings.respond_to? c_option
			        c = "#{c_option}="
			        Opal::Config.send(c,settings.send(c_option))
			    end 
			end

			# method_missing_enabled:    true,
	  		#arity_check_enabled:       false,
	  		#const_missing_enabled:     true,
	  		#dynamic_require_severity:  :error, # :error, :warning or :ignore
	  		#irb_enabled:               false,
	  		#inline_operators_enabled:  true,
	  		#source_map_enabled:        true,

			configure do
				Tilt.register Tilt::ERBTemplate, 'html.erb'
				assets.defaults.each do |key,to_value|
					unless settings.respond_to? key
						set key, ( to_value.respond_to?(:call) ? self.instance_exec(&to_value) : to_value) 
					end
				end 

				Sprockets::Helpers.configure do |config|
					config.prefix = settings.prefix
					config.digest = settings.digest
					config.public_path = settings.public_path	
					config.environment = settings.sprockets
					config.debug       = true unless ENV['RACK_ENV'] == 'production'
				end

				::Sass.load_paths << "#{settings.asset_folder}/" + assets.find_css_path(self.asset_folders)
			end

			if ENV['RACK_ENV'] == 'production'
				Opal::Config.source_map_enabled = false
			else
				Opal::Config.source_map_enabled = false
			end
			
			##add asset routes for prefix folder
			
			get %r{/#{settings.prefix}/(.*|(?:.*/.*))(\W.*)$} do
				self.instance_exec(*params[:captures],&assets.get_asset)
			end
			#add asset types
			settings.asset_folders.each do |asset_type|
				get %r{/#{settings.prefix}/#{asset_type}/(.*|(?:.*/.*))(\W.*)$} do
					self.instance_exec(*params[:captures],&assets.get_asset)
				end
			end
			
			
			helpers Sprockets::Helpers

			
		end
	end

end
