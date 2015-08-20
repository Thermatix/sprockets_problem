
def get_by_id id
	`document.getElementById(#{id})`
end


def render_component component,mount_point
	React.render React.create_element(component), mount_point
end