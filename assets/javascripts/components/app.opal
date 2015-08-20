class App < Base
	define_state(:logged_in) {:false}
	define_state(:flash){{}}


	def render
		present Flash, data: self.flash, app: self
	end

end