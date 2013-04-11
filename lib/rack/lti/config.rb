module Rack::LTI
  class Config < Hash
    DEFAULT = {
      app_path:    '/',
      config_path: '/lti/config.xml',
      description: 'An LTI Application.',
      launch_path: '/lti/launch',
      time_limit:  60*60,
      title:       'LTI App'
    }

    def initialize(options = {})
      DEFAULT.merge(options).each do |k, v|
        self[k] = v
      end
    end

    def method_missing(method, *args, &block)
      if method.match(/=$/)
        self[method.to_s[0..-2].to_sym] = args.first
      else
        self[method]
      end
    end
  end
end
