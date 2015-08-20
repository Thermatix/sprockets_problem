class Base 
	include React::Component
	include React_State_Machine
	def initialize(native)
		@native = native
	end

end

