class Flash < Base
	
	optional_param  :data
	before_mount do
		define_state(:data) {params[:data] || {}}
		@timer = nil
		@app =  params[:app]
	end

	def vanish_message
		sleep_for 5000 do
 			self.data = {}
		end
	end

	after_mount :vanish_message


	def render
		div( id: "flash_box", class_name: "flash_#{self.data[:type] || "blank"}" ) do 
			self.data[:message] || ""
		end
	end

end