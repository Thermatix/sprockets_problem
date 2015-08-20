require 'opal'
require "json"
require "react"
require 'opal-jquery'

require 'components/helpers'
require 'components/base'
require 'components/spinner'
require 'components/app'

Document.ready? do
	render_component App, get_by_id('view_port')
end