module React_State_Machine

	def check_intial_state
			raise "no initial state set, please use `set_initial_state STATE`" unless get_current_state
		end

	def get_current_state
		send(self.class.state_name)
	end

	def set_current_state value
		send("#{self.class.state_name}=",value)
	end
	

	def use_(callback)
		if callback
			if callback.lambda?
				callback.call 
			else
				send(callback)
			end
		end
	end	

	def can_transition_(from)
		[from].flatten.include?(get_current_state)
	end


	def using_state_action
		action = self.class.state_actions[get_current_state]
		if action.respond_to?(:call)
			self.instance_eval(&action)
		else
			send(action)
		end
	end
	


	module API	

		def state_action state, func_name=nil &block
			@state_actions ||= {}
			@state_actions[state] = func_name||block
		end


		def state_name
			@state_name || 'current_state'
		end

		def set_state_name name
			@state_name = name
		end

		def create_state state
			@states ||= []
			@states << state
			define_method "#{state}?" do
				check_intial_state
				get_current_state == state
			end
		end

		def create_states states
			states.each do |state|
				create_state state
			end
		end


		def set_initial_state state
			@initial_state = state
			define_state(state_name){state} 
		end

		def event name,data, &callback
			@events ||= []
			@events << name
			define_method "#{name}!" do
				check_intial_state
				use_(data[:before])
				if can_transition_(data[:from]) 
					set_current_state data[:to] 
					callback.call if block_given?
				else
					use_(data[:fail])
				end
			end
			define_method "may_#{name}?" do
				check_intial_state
				get_current_state == data[:from]
			end
		end

	end


	def self.included(base)
		base.extend API
	end

end
