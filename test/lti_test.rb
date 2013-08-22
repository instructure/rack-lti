require 'minitest/autorun'
require 'rack-lti'

class LtiTest < Minitest::Test
  def setup
    @app = ->(env) { [200, [], ['Hi']] }
  end

  def test_lti_proxies_new_calls_to_middleware
    assert_instance_of Rack::LTI::Middleware, Rack::LTI.new(@app)
  end
end
