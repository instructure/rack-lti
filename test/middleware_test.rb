require 'minitest/autorun'
require 'rack'
require 'rack/lti/middleware'

class MiddlewareTest < Minitest::Unit::TestCase
	def setup
		@app     = ->(env) { [200, {}, ['hi']] }
		@lti_app = Rack::LTI::Middleware.new(@app)
    @params  = {
      lti_message_type:    'basic-lti-launch-request',
      lti_version:         'LTI-1p0',
      resource_link_id:    '88391-e1919-bb3456',
      resource_link_title: 'Resource Title',
      user_id:             '0ae836b9-7fc9-4060-006f-27b2066ac545',
      roles:               'instructor',
      oauth_nonce:         '12345',
      oauth_timestamp:     Time.now.to_i.to_s
    }.reduce({}) { |m, h| m[h[0].to_s] = h[1]; m }
	end

	def test_middleware_accepts_an_app
		assert_equal @lti_app.app, @app
	end

	def test_routes_returns_the_recognized_routes
		known_routes = { @lti_app.config.config_path => :config_action,
			@lti_app.config.launch_path => :launch_action }
		assert_equal known_routes, @lti_app.routes	
	end

	def test_call_returns_a_valid_rack_response
		response = @lti_app.call(Rack::MockRequest.env_for('/'))

		assert_equal response, @app.call(nil)
	end

	def test_call_intercepts_known_routes
		env = Rack::MockRequest.env_for('/lti/launch')
		@lti_app.call(env)

		assert_equal true, env['rack.lti']
	end

	def test_call_ignores_unknown_routes
		env = Rack::MockRequest.env_for('/')
		@lti_app.call(env)

		assert_equal nil, env['rack.lti']
	end

	def test_call_returns_403_on_invalid_launch
		@lti_app.stub(:valid?, false) do
			response = @lti_app.call(Rack::MockRequest.env_for('/lti/launch'))
			assert_equal 403, response[0]
		end
	end

  def test_call_returns_403_on_invalid_nonce
    @lti_app.config.nonce_validator ->(nonce) { false }

    @lti_app.stub(:valid_request?, true) do
      response = @lti_app.call(Rack::MockRequest.env_for('/lti/launch'))
      assert_equal 403, response[0]
    end
  end

  def test_call_returns_403_on_expired_timestamp
    @lti_app.config.nonce_validator = true
    @lti_app.config.time_limit      = 30

    @lti_app.stub(:valid_request?, true) do
      env      = Rack::MockRequest.env_for('/lti/launch',
                                           oauth_timestamp: Time.now - 60*60)
      response = @lti_app.call(env)
      assert_equal 403, response[0]
    end
  end

  def test_call_stores_launch_params_in_the_session
    @lti_app.stub(:valid_request?, true) do
      env = Rack::MockRequest.env_for('/lti/launch', method: 'post',
                                      'rack.session' => {},
                                      params: @params)
      @lti_app.call(env)
      assert_equal @params.keys.sort,
                   env['rack.session']['launch_params'].keys.sort
    end
  end

  def test_call_redirects_to_app_path_on_success
    @lti_app.stub(:valid_request?, true) do
      env = Rack::MockRequest.env_for('/lti/launch', method: 'post',
                                      params: @params)
      response = @lti_app.call(env)
      assert_equal 301, response[0]
      assert_equal @lti_app.config[:app_path], response[1]['Location']
    end
  end

  def test_call_succeeds_if_sessions_are_not_used
    @lti_app.stub(:valid_request?, true) do
      env = Rack::MockRequest.env_for('/lti/launch', method: 'post',
                                      params: @params)
      response = @lti_app.call(env)
      assert_equal 301, response[0]
    end
  end
end
