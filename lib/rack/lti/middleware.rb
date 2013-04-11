require 'ims/lti'
require 'oauth/request_proxy/rack_request'
require 'rack/lti/config'

module Rack::LTI
	class Middleware
		attr_reader :app, :config

		def initialize(app, options = {})
			@app    = app	
			@config = Config.new(options)
		end

		def call(env)
			request = Rack::Request.new(env)
			if routes.values.include?(request.path)
				env['rack.lti'] = true
			end

			@app.call(env)
		end

		def routes
			{ config: @config.config_path, launch: @config.launch_path }
		end
	end
end
