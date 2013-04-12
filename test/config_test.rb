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
    assert_equal true,                  @config.nonce_validator
    assert_equal 3600,                  @config.time_limit
    assert_equal 'LTI App',             @config.title
  end

  def test_consumer_key_returns_primitive_values
    @config[:consumer_key] = 1
    assert_equal 1, @config.consumer_key
  end

  def test_consumer_key_calls_a_proc_if_given
    @config[:consumer_key] = ->(n) { n + 1 }
    assert_equal 2, @config.consumer_key(1)
  end

  def test_consumer_secret_returns_primitive_values
    @config[:consumer_secret] = 1
    assert_equal 1, @config.consumer_secret
  end

  def test_consumer_secret_calls_a_proc_if_given
    @config[:consumer_secret] = ->(n) { n + 1 }
    assert_equal 2, @config.consumer_secret(1)
  end

  def test_nonce_validator_returns_primitive_values
    @config[:nonce_validator] = 1
    assert_equal 1, @config.nonce_validator
  end

  def test_nonce_validator_calls_a_proc_if_given
    @config[:nonce_validator] = ->(n) { n + 1 }
    assert_equal 2, @config.nonce_validator(1)
  end
end
