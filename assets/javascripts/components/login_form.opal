class Login_Form  < Base
	optional_param :username
	required_param :owner

	def fix_button
		sleep_for 0.0000000000000000001 do
			if(el = Element["i.waves-effect.waves-light.btn.waves-input-wrapper.waves-input-wrapper"])
				input = el.find ".waves-button-input"
				input.class_name = "waves-button-input waves-effect waves-light btn waves-input-wrapper waves-input-wrapper"
				el.parent.html(input)
			end
		end
	end
	
	before_mount do
		@owner = params[:owner]
	end

	def form_submit_action
		login_form = Element["#login_form"]
		
		login_form.on :submit do |event|
			unless @owner.login_state == :processing 
				@form_ajax = true
				event.prevent_default
				username = login_form.find('#username').value
				password = login_form.find('#password').value
				@owner.login!
				@owner.username = username
				@owner.handle_login_submit({username: username , password: password})
			end 
		end
	end

	after_mount do
		form_submit_action
		fix_button
	end

	def render
		form class_name: (col 12), id: 'login_form' do
			div class_name: "input-field #{col 4}" do
				label(html_for: "username", class_name: params[:username] ? "active" : "") {"username"}
				input type: "text",id: "username",ref: :username, class_name: "validate",  defaultValue: params[:username]
			end
			div class_name: "input-field #{col 4}" do
				label(html_for: "password") {"password"}
				input type: "password",id: "password",  ref: :password, class_name: "validate"
			end
			div class_name: "input-field #{col 4}" do
				input type: "submit", value: "Login", class_name:"waves-effect waves-light btn waves-input-wrapper"
			end
		end
	end

end