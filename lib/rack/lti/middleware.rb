require 'ims/lti'
require 'oauth/request_proxy/rack_request'
require 'rack/lti/config'

module Rack::LTI
	class Middleware
		attr_reader :app, :config

		def initialize(app, options = {}, &block)
			@app    = app	
			@config = Config.new(options, &block)
		end

		def call(env)
			request = Rack::Request.new(env)
			@status, @headers, @response = @app.call(env)

			if routes.has_key?(request.path)
				env['rack.lti'] = true
				send(routes[request.path], request, env)
        @headers['Content-Length'] = @response[0].length.to_s
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
      @status = 200
      @response = [@config.to_xml(launch_url: 'http://localhost:9393/lti/launch')]
      @headers['Content-Type'] = 'application/xml'
		end

		def launch_action(request, env)
			provider = IMS::LTI::ToolProvider.new(@config.consumer_key,
																						@config.consumer_secret,
																						request.params)

			if valid?(provider, request)
				env['rack.session']['launch_params'] = provider.to_params	if env['rack.session']
        @status = 301
        @headers['Location'] = @config.app_path
			else
				@status   = 403
				@response = ['Invalid launch.']
			end
		end

		def valid?(provider, request)
			valid_request?(provider, request) &&
        valid_nonce?(request.params['oauth_nonce']) &&
        valid_timestamp?(request.params['oauth_timestamp'].to_i)
		end

    def valid_request?(provider, request)
      @config.public? ? true : provider.valid_request?(request)
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
