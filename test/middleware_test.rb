require 'minitest/autorun'
require 'rack'
require 'rack/lti/middleware'

class MiddlewareTest < Minitest::Unit::TestCase
	def setup
		@app     = ->(env) { [200, {}, ['hi']] }
		@lti_app = Rack::LTI::Middleware.new(@app)
	end

	def test_middleware_accepts_an_app
		assert_equal @lti_app.app, @app
	end

	def test_routes_returns_the_recognized_routes
		known_routes = { config: @lti_app.config.config_path,
			launch: @lti_app.config.launch_path }
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
end
