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

      if routes.has_key?(request.path)
        env['rack.lti'] = true
        send(routes[request.path], request, env)
      else
        @app.call(env)
      end
    end

    def routes
      {
        @config.config_path => :config_action,
        @config.launch_path => :launch_action
      }
    end

    private

    def config_action(request, env)
      launch_url = request.url.sub(@config.config_path, @config.launch_path)
      response = [@config.to_xml(request, launch_url: launch_url)]
      [200, { 'Content-Type' => 'application/xml', 'Content-Length' => response[0].length.to_s }, response]
    end

    def consumer_key_wrapper(key, consumer_id, req)
      @config.consumer_key(key, consumer_id, req)
    rescue ArgumentError
      # Maintain backwards compatibility with previous #consumer_key signature
      @config.consumer_key(key, consumer_id)
    end

    def consumer_secret_wrapper(key, consumer_id, req)
      @config.consumer_secret(key, consumer_id, req)
    rescue ArgumentError
      # Maintain backwards compatibility with previous #consumer_secret signature
      @config.consumer_secret(key, consumer_id)
    end

    def launch_action(request, env)
      provider = IMS::LTI::ToolProvider.new(consumer_key_wrapper(*request.params.values_at('oauth_consumer_key', 'tool_consumer_instance_guid'), request),
                                            consumer_secret_wrapper(*request.params.values_at('oauth_consumer_key', 'tool_consumer_instance_guid'), request),
                                            request.params)

      if valid?(provider, request)
        req = Rack::Request.new(env)
        res = Rack::Response.new([], 302, { 'Content-Length' => '0',
          'Content-Type' => 'text/html', 'Location' => @config.app_path })
        @config.success.call(provider.to_params, req, res)
        if @config.redirect
          res.finish
        else
          @app.call(env)
        end
      else
        response = 'Invalid launch.'
        [403, { 'Content-Type' => 'text/plain', 'Content-Length' => response.length.to_s }, [response]]
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
      if @config[:nonce_validator].respond_to?(:call)
        @config.nonce_validator(nonce)
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
