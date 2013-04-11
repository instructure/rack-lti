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
			@status, @headers, @response = @app.call(env)

			if routes.has_key?(request.path)
				env['rack.lti'] = true
				send(routes[request.path], request)
			end

			[@status, @headers, @response]
		end

		def routes
			{
				@config.config_path => :config_action,
				@config.launch_path => :launch_action
			}
		end

		private
		def config_action(request)
						
		end

		def launch_action(request)
			provider = IMS::LTI::ToolProvider.new(@config.consumer_key,
																						@config.consumer_secret,
																						request.params)

			if valid?(provider, request)
				env['rack.session']['launch_params'] = provider.to_params	if env['rack.session']
			else
				@status   = 403
				@response = []
				@headers['Content-Length'] = 0
			end
		end

		def valid?(provider, request)
			provider.valid_request?(request)
		end
	end
end
