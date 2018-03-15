require 'minitest/autorun'
require 'rexml/document'
require 'rack/lti/config'

class ConfigTest < Minitest::Test
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

  def test_config_accepts_a_block
    config = Rack::LTI::Config.new do |c|
      c[:title] = 'custom title'
    end

    assert_equal 'custom title', config[:title]
  end

  def test_config_populates_default_values
    assert_equal '/',                   @config.app_path
    assert_equal '/lti/config.xml',     @config.config_path
    assert_equal 'An LTI Application.', @config.description
    assert_equal '/lti/launch',         @config.launch_path
    assert_equal true,                  @config.nonce_validator
    assert_equal 3600,                  @config.time_limit
    assert_equal nil,                   @config.future_time_limit
    assert_equal 'LTI App',             @config.title
    assert_equal true,                  @config.redirect
    assert_instance_of Proc,            @config.success
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

  def test_public_returns_true_if_no_key_or_secret_is_set
    @config[:consumer_key]    = nil
    @config[:consumer_secret] = nil
    assert @config.public?
  end

  def test_to_xml_returns_an_xml_lti_config
    body = REXML::Document.new(@config.to_xml(nil, launch_url: 'http://example.com/launch'))

    assert_equal @config.title,
                 REXML::XPath.match(body, '//blti:title').first.text
    assert_equal @config.description,
                 REXML::XPath.match(body, '//blti:description').first.text
    assert_equal 'http://example.com/launch',
                 REXML::XPath.match(body, '//blti:launch_url').first.text
  end

  def test_to_xml_includes_hardcoded_extensions
    @config[:extensions] = {
      'canvas.instructure.com' => {
        'course_navigation' => {
          'privacy_level' => 'anonymous',
          'text'          => 'Tool title',
          'url'           => 'http://example.com'
        }
      }
    }

    body = REXML::Document.new(@config.to_xml(nil, launch_url: 'http://example.com/launch'))
    assert_equal 'anonymous',
                 REXML::XPath.match(body, '//lticm:property[@name="privacy_level"]').first.text
    assert_equal 'Tool title',
                 REXML::XPath.match(body, '//lticm:property[@name="text"]').first.text
    assert_equal 'http://example.com',
                 REXML::XPath.match(body, '//lticm:property[@name="url"]').first.text
  end

  def test_to_xml_includes_extensions_with_lambdas
    rack_request_stub = Struct.new(:base_url).new('rack-url.com')
    @config[:extensions] = {
      'canvas.instructure.com' => ->(req) do
        {
          'editor_button' => {
            'size'     => '16x16',
            'icon_url' => "#{req.base_url}/public/icon.png"
          }
        }
      end
    }

    body = REXML::Document.new(@config.to_xml(rack_request_stub, launch_url: 'http://example.com/launch'))
    assert_equal '16x16',
                 REXML::XPath.match(body, '//lticm:property[@name="size"]').first.text
    assert_equal 'rack-url.com/public/icon.png',
                 REXML::XPath.match(body, '//lticm:property[@name="icon_url"]').first.text
  end

  def test_to_xml_includes_custom_params
    @config[:custom_params] = { ck1: 'one', ck2: 'two' }
    body = REXML::Document.new(@config.to_xml(nil, launch_url: 'http://example.com/launch'))
    assert_equal 'one', REXML::XPath.match(body, '//blti:custom/lticm:property[@name="ck1"]').first.text
    assert_equal 'two', REXML::XPath.match(body, '//blti:custom/lticm:property[@name="ck2"]').first.text
  end
end
