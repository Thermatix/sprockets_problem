require "opal_libs"
require "components"

Document.ready? do
	render_component App, get_by_id('view_port')
end