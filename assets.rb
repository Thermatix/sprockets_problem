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

	@get_asset = Proc.new do |file_name,extention,asset_type=nil|
		content_type mime_types[extention]
		path = file_name + extention#[asset_type,file_name + extention].compact.join('/')
		env_sprockets = request.env.dup
		env_sprockets['PATH_INFO'] = path
		puts path
		settings.assets[path]
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
			# set_default :root, Dir.pwd
			# set_default :asset_folder, 'assets'

			unless ENV['RACK_ENV'] == 'production'

			end
			asset_types = nil
			asset_root = nil
			configure do

				set :assets, Sprockets::Environment.new { |env|
					env.register_engine '.orb', Opal::Processor

					# ##set up opal paths
					Opal.paths.each {|p|env.append_path p}

					##set up "traditional" assets
					# env.append_path settings.root 
					asset_root = "#{settings.root}/#{settings.asset_folder}"
					env.append_path asset_root
					(asset_types = %w{javascripts stylesheets fonts images}).each do |asset_folder|
						env.append_path "#{asset_root}/*"
					end

					#set up compressers and pre-proccessors
					env.js_compressor = YUI::JavaScriptCompressor.new
					env.css_compressor = :sass
				}
				::Sass.load_paths << asset_root
			end
			Opal::Processor.source_map_enabled = false
			##add asset routes for asset_folder folder
			
			get %r{/#{settings.asset_folder}/(.*)(\W.*)$} do
				s =	self.instance_exec(*params[:captures],&assets.get_asset)
				puts s unless params[:captures].last == ".js"
				s
			end

			#add asset types
			asset_types.each do |asset_type|
				get %r{/#{settings.asset_folder}/#{asset_type}/(.*)(\W.*)$} do
					s = self.instance_exec(*params[:captures],asset_type,&assets.get_asset)
					puts s
					s
				end
			end
		end
	end

end