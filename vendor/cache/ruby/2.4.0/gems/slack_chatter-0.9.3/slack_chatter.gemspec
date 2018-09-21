# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack_chatter/version'

Gem::Specification.new do |spec|
  spec.name          = "slack_chatter"
  spec.version       = SlackChatter::VERSION
  spec.authors       = ["Will Bryant"]
  spec.email         = ["will.t.bryant@gmail.com"]

  spec.summary       = %q{Simple to use SlackChatter wrapper}
  spec.description   = %q{Simple to use Slack API wrapper which makes it easy to access and use the Slack API client without much knowledge of how it works}
  spec.homepage      = "https://github.com/will3216/slack_chatter"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-encoding-matchers'
  spec.add_dependency 'json', '>= 1.7.7'
  spec.add_dependency 'httmultiparty'
  spec.add_dependency 'rake'
  spec.add_dependency 'activesupport'
end
