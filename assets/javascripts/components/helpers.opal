

def render_component component,mount_point
	React.render React.create_element(component), mount_point
end

def col val
	"col s#{val}"
end


def get_by_id id
	`document.getElementById(#{id})`
end


def sleep_for(time)
	%x|window.setTimeout(function (){#{yield}},#{time})|
end

def event object,type
	%x|#{object}.addEventListener(#{type}, function(event) { #{yield(event)} })|
end
