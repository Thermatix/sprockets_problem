class App < Base

	set_state_name :app_state
	create_states %w{login search}
	set_initial_state :login

	event :logged_in,{from: :login, to: :search}
	event :logged_out,{from: :search, to: :login}

	state_action :login,:display_login
	state_action :search, :display_search

	define_state :logged_in, :false
	define_state :flash, {} 

	def display_login
		present LoginForm, app: self
	end

	def display_search
		"logged in, yay"
	end

	def render
		present Flash, data: self.flash, app: self
		using_state_action
	end

end
