require 'ims/lti'

module Rack::LTI
  class Config < Hash
    DEFAULT = {
      app_path:        '/',
      config_path:     '/lti/config.xml',
      description:     'An LTI Application.',
      launch_path:     '/lti/launch',
      nonce_validator: true,
      redirect:        true,
      success:         ->(lti, req, res) {
        req.session['launch_params'] = lti if req.env['rack.session']
      },
      time_limit:      60*60,
      title:           'LTI App'
    }

    def initialize(options = {})
      DEFAULT.merge(options).each { |k, v| self[k] = v }
      instance_eval { yield(self) } if block_given?
    end

    [:consumer_key, :consumer_secret, :nonce_validator].each do |method|
      define_method(method) do |*args|
        if self[method].respond_to?(:call)
          # Only pass the arguments supported by this lambda
          supported_args = args.take(self[method].parameters.length)
          self[method].call(*supported_args)
        else
          self[method]
        end
      end
    end

    def public?
      self[:consumer_key].nil? && self[:consumer_secret].nil?
    end

    def to_xml(request, options = {})
      options = options.merge(get_extensions(request))

      # Stringify keys for IMS::LTI
      config = self.merge(options).inject({}) do |h, v|
        h[v[0].to_s] = v[1]
        h
      end

      IMS::LTI::ToolConfig.new(config).to_xml(indent: 2)
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

    private

    def get_extensions(request)
      return {} unless self.key? :extensions
      extensions = self[:extensions].inject({}) do |h, (k, v)|
        h[k] = v.respond_to?(:call) ? v.call(request) : v
        h
      end
      { extensions: extensions }
    end
  end
end
