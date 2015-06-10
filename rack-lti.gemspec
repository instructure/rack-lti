# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/lti/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-lti'
  spec.version       = Rack::LTI::VERSION
  spec.authors       = ['Zach Pendleton']
  spec.email         = ['zachpendleton@gmail.com']
  spec.description   = <<-END
    Rack::LTI provides LTI launch and configuration endpoints to your
    Rack-based application. It handles configuration, authorization, and
    routing.

    For more information about LTI, see http://www.imsglobal.org/toolsinteroperability2.cfm.
  END
  spec.summary       = %q{Middleware for handling LTI launches inside your Rack app.}
  spec.homepage      = 'https://github.com/zachpendleton/rack-lti'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'ims-lti', '~> 1.1'
  spec.add_dependency 'rack'
end
