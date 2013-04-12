require 'rack/lti/config'
require 'rack/lti/middleware'
require 'rack/lti/version'

module Rack
  module LTI
    def self.new(*args, &block)
      Middleware.new(*args, &block)
    end
  end
end
