# Rack::LTI

[![Build Status](https://travis-ci.org/zachpendleton/rack-lti.png)](https://travis-ci.org/zachpendleton/rack-lti)

Rack::LTI exposes LTI launch and config URLs in your Rack application, handling
authorization, storing launch parameters, and generating config information for
consumers.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-lti'

## Usage

### Rails 3

Add Rack::LTI to your `config/application.rb`:

```ruby
class Application < Rails::Application
  config.middleware.use Rack::LTI,
    consumer_key:    ->(key, consumer_id) { key == 'key_value' },
    consumer_secret: ->(secret) { secret == 'top_secret' }

    app_path:    '/',
    config_path: '/lti/config.xml',
    launch_path: '/lti/launch',

    title:       'My LTI App',
    description: 'My LTI App description',

    nonce_validator: ->(nonce) { !FakeNonceStore.include?(nonce) }
    time_limit: 60*60,

    extensions: {
      'canvas.instructure.com' => {
        course_navigation: {
          default: 'enabled',
          text: 'My LTI App'
        }
      }
    }
end
```

### Sinatra

Add Rack::LTI to your app:

```ruby
class Application < Sinatra::Base
  use Rack::LTI,
    consumer_key:    'my_key'
    consumer_secret: 'my_secret'

    app_path:    '/',
    config_path: '/lti/config.xml',
    launch_path: '/lti/launch',

    title:       'My LTI App',
    description: 'My LTI App description',

    nonce_validator: ->(nonce) { !FakeNonceStore.include?(nonce) }
    time_limit: 60*60,

    extensions: {
      'canvas.instructure.com' => {
        course_navigation: {
          default: 'enabled',
          text: 'My LTI App'
        }
      }
    }
end
```

## Configuration

Rack::LTI takes either a configuration hash or block at initialization. Allowed
values are:

  * `consumer_key`: The consumer_key to check against the key given at launch.
    This value can be a string or a lambda. If a lambda, it is passed the key
    used by the consumer as well as their tool_consumer_instance_guid.
  * `consumer_secret`: The consumer_secret to check against the secret given at
    launch. Like the consumer key, this value can be a string or a lambda. If a
    lambda, it is passed the key and tool_consumer_instance_guid of the
    consumer.
  * `app_path`: The path to redirect to on a successful launch. This should be
    the main page of your application. Defaults to '/'.
  * `config_path`: The path to serve LTI config XML from. Defaults to
    '/lti/config.xml'.
  * `launch_path`: The path to receive LTI launch requests at. Defaults to
    '/lti/launch'.
  * `title`: The title of your LTI application.
  * `description`: The description of your LTI application.
  * `nonce_validator`: A lambda used to validate the current request's nonce.
    It is passed the nonce to verify. If not provided, all nonces are allowed.
  * `time_limit`: The time limit, in seconds, to consider requests valid within.
    If not passed, the default is 3600 seconds (one hour).
  * `extensions`: A hash of extension information to include with the config.
    Format is platform -> option -> properties. See usage examples above for
    more detail.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
