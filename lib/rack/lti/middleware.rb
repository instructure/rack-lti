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
				send(routes[request.path], request, env)
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

		def config_action(request, env)
						
		end

		def launch_action(request, env)
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
			valid_request?(provider, request) &&
        valid_nonce?(request.params['oauth_nonce']) &&
        valid_timestamp?(request.params['oauth_timestamp'].to_i)
		end

    def valid_request?(provider, request)
      provider.valid_request?(request)
    end

    def valid_nonce?(nonce)
      if @config.nonce_validator.respond_to?(:call)
        @config.nonce_validator.call(nonce)
      else
        @config.nonce_validator
      end
    end

    def valid_timestamp?(timestamp)
      if @config.time_limit.nil?
        true
      else
        (Time.now.to_i - @config.time_limit) <= timestamp
      end
    end
	end
end
