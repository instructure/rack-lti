module Rack::LTI
  class Config < Hash
    DEFAULT = {
      app_path:        '/',
      config_path:     '/lti/config.xml',
      description:     'An LTI Application.',
      launch_path:     '/lti/launch',
      nonce_validator: true,
      time_limit:      60*60,
      title:           'LTI App'
    }

    def initialize(options = {})
      DEFAULT.merge(options).each do |k, v|
        self[k] = v
      end
    end

    [:consumer_key, :consumer_secret, :nonce_validator].each do |method|
      define_method(method) do |*args|
        if self[method].respond_to?(:call)
          self[method].call(*args)
        else
          self[method]
        end
      end
    end

    def public?
      self[:consumer_key].nil? && self[:consumer_secret].nil?
    end

    def method_missing(method, *args, &block)
      if method.match(/=$/)
        self[method.to_s[0..-2].to_sym] = args.first
      elsif self.has_key?(method)
        self[method]
      else
        super
      end
    end
  end
end
