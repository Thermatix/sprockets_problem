class App < Base

	set_state_name :app_state
	create_states %w{login search}
	set_initial_state :login

	event :logged_in,{from: :login, to: :search}
	event :logged_out,{from: :search, to: :login}

	state_action(:login) {present LoginForm, app: self}
	state_action(:search) {"logged in, yay"}

	define_state :logged_in, :false
	define_state :flash, {} 


	def render
		present Flash, data: self.flash, app: self
		using_state_action
	end

end