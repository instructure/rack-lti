# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/lti/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-lti'
  spec.version       = Rack::LTI::VERSION
  spec.authors       = ['Zach Pendleton']
  spec.email         = ['zachpendleton@gmail.com']
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = 'https://github.com/zachpendleton/rack-lti'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 4.7.0'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'ims-lti', '~> 1.1.2'
end
