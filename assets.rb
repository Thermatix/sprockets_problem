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
	end

	@get_asset = Proc.new do |captures|
		file_name,extention = captures
		content_type mime_types[extention]
		settings.assets.instance_exec do 
			puts 'assets'
			puts @assets
		end
		settings.assets["#{file_name}.#{extention}"]
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
			unless ENV['RACK_ENV'] == 'production'

			end
			asset_types = nil
			configure do
				set :assets, Sprockets::Environment.new(settings.root)
				settings.assets.tap do |s|
					s.register_engine '.orb', Opal::Processor

					##set up opal paths
					Opal.paths.each {|p| s.append_path p}

					##set up "traditional" assets
					s.append_path settings.asset_root
					(asset_types = %w{javascripts stylesheets fonts images}).each do |asset_folder|
						s.append_path "#{settings.asset_root}/#{asset_folder}"
					end

					#set up compressers and pre-proccessors
					s.js_compressor = :yui
					s.css_compressor = :sass
				end
				
			end
			Opal::Processor.source_map_enabled = false
			puts settings.assets.paths.to_s
			##add asset routes for asset_root folder
			
			get %r{/#{settings.asset_root}/(.*)(\W.*)$} do
				puts params[:captures].to_s
				s =	self.instance_exec(params[:captures],&assets.get_asset)
				puts "#{params[:captures].join('')}:"
				puts s
				s
			end

			#add asset types
			asset_types.each do |asset_type|
				get %r{/#{settings.asset_root}/#{asset_type}/(.*)(\W.*)$} do
					puts params[:captures].to_s
					s = self.instance_exec(params[:captures],&assets.get_asset)
					puts "#{params[:captures].join('')}:"
					puts s
					s
				end
			end
		end
	end

end