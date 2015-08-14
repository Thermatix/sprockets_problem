require "yui/compressor"
require "sass"
require 'sprockets'
require 'opal'

module Assets
	
	Opal = ::Opal
	Sprockets = ::Sprockets
	

	class << self
		attr_reader :get_asset
		attr_accessor :opal_config

		def defaults
			{
				root: Dir.pwd,
				asset_folder: 'assets',
				asset_folders: %w{javascripts stylesheets fonts images},
				assets: -> { 
					Sprockets::Environment.new do |env|
						asset_root = "#{settings.root}/#{settings.asset_folder}"
						#register opal with sprockets
						env.register_engine '.orb', Opal::Processor					
						Opal.paths.each {|p|env.append_path p}
						
						#set up asset root folder
						env.append_path asset_root
						#set up compressers and pre-proccessors
						env.js_compressor = YUI::JavaScriptCompressor.new
						env.css_compressor = :sass
					end
				}
			}
		end

		def find_css_path a_r
			Dir.exist?("#{a_r}/stylesheets") ? "#{a_r}/stylesheets" :  "#{a_r}/css"			
		end
	end

	@get_asset = Proc.new do |file_name,extention,asset_type=nil|
		content_type mime_types[extention]
		settings.assets[[asset_type,"#{file_name}#{extention}"].compact.join('/')]
	end

	def mime_types
		{
			".css" 	=> 	"text/css",
			".js" 	=> 	"application/javascript",
			".jpeg" =>	"image/jpeg",
	 		".jpg"	=> 	"image/jpeg"
		}
	end
	

	def self.included base
		base.class_exec(self) do |assets|

			if ENV['RACK_ENV'] == 'production'
				Opal::Processor.source_map_enabled = false
			else
				Opal::Processor.source_map_enabled = false
			end

			asset_root = "#{settings.root}/#{settings.asset_folder}"
			configure do
				assets.defaults.each do |key,to_value|
					set key, ( to_value.respond_to?(:call) ? self.instance_exec(&to_value) : to_value) unless settings.respond_to? key
				end 
				::Sass.load_paths << assets.find_css_path(asset_root)
			end

			
			##add asset routes for asset_folder folder
			
			get %r{/#{settings.asset_folder}/(.*)(\W.*)$} do
				self.instance_exec(*params[:captures],&assets.get_asset)
			end

			#add asset types
			settings.asset_folders.each do |asset_type|
				get %r{/#{settings.asset_folder}/#{asset_type}/(.*)(\W.*)$} do
					self.instance_exec(*params[:captures],asset_type,&assets.get_asset)
				end
			end
		end
	end

end