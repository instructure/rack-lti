require 'minitest/autorun'
require 'rack/lti/config'

class ConfigTest < Minitest::Unit::TestCase
  def setup
    @config = Rack::LTI::Config.new
  end

  def test_config_accepts_hash_style_setters
    @config[:setting] = 'value'
    assert_equal 'value', @config[:setting]
  end

  def test_config_accepts_accessor_style_setters
    @config.setting = 'value'
    assert_equal 'value', @config.setting
  end

  def test_config_populates_default_values
    assert_equal '/',                   @config.app_path
    assert_equal '/lti/config.xml',     @config.config_path
    assert_equal 'An LTI Application.', @config.description
    assert_equal '/lti/launch',         @config.launch_path
    assert_equal 3600,                  @config.time_limit
    assert_equal 'LTI App',             @config.title
  end
end
