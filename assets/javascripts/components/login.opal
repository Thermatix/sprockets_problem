
class Login < Base

	required_param :app
	set_state_name :login_state
	create_states %w{waiting processing return_failed return_success}
	set_initial_state :waiting

	event :login,{from: :waiting, to: :processing}
	event :fail,{from: :processing, to: :return_failed}
	event :succeed,{from: :processing, to: :return_success} 
	event :wait,{from: :return_failed, to: :waiting} 
	
	define_state(:username){ nil}

	before_mount do
		@app = params[:app]
		@flash = @app.flash
	end

	def render
		div id: 'login_wrapper' do
			div class_name: 'row' do
				
				case login_state
				when :processing
					 present Spinner
				when :return_success
					div( id:"login_success", class_name: "waves-effect waves-light btn waves-input-wrapper") { "Ok" }
 				else
					present Login_Form, username: self.username, owner: self
				end
			end

		end
	end


	def handle_login_submit details
		url = "/client/api/auth"
		HTTP.post url, payload: details.to_json, dataType: 'json' do |response|
			if response.status_code != 500
				data = response.json
				if data[:success]
					@flash = {type: :message}.update(data)
					succeed!
				else
					@flash = {type: :alert}.update(data)
					fail!
					remove_flash
				end
			else
				@flash = {type: :error, message: "There was a server error" }
				self.login_state = :return_failed
				remove_flash
			end
		end
	end

end
