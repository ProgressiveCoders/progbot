# -*- encoding: utf-8 -*-
# stub: draper 3.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "draper".freeze
  s.version = "3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jeff Casimir".freeze, "Steve Klabnik".freeze]
  s.date = "2017-10-12"
  s.description = "Draper adds an object-oriented layer of presentation logic to your Rails apps.".freeze
  s.email = ["jeff@casimircreative.com".freeze, "steve@steveklabnik.com".freeze]
  s.homepage = "http://github.com/drapergem/draper".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "2.6.14".freeze
  s.summary = "View Models for Rails".freeze

  s.installed_by_version = "2.6.14" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["~> 5.0"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["~> 5.0"])
      s.add_runtime_dependency(%q<request_store>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<activemodel>.freeze, ["~> 5.0"])
      s.add_runtime_dependency(%q<activemodel-serializers-xml>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<ammeter>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<active_model_serializers>.freeze, ["~> 0.10"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["~> 5.0"])
      s.add_dependency(%q<actionpack>.freeze, ["~> 5.0"])
      s.add_dependency(%q<request_store>.freeze, ["~> 1.0"])
      s.add_dependency(%q<activemodel>.freeze, ["~> 5.0"])
      s.add_dependency(%q<activemodel-serializers-xml>.freeze, ["~> 1.0"])
      s.add_dependency(%q<ammeter>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
      s.add_dependency(%q<minitest-rails>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<active_model_serializers>.freeze, ["~> 0.10"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["~> 5.0"])
    s.add_dependency(%q<actionpack>.freeze, ["~> 5.0"])
    s.add_dependency(%q<request_store>.freeze, ["~> 1.0"])
    s.add_dependency(%q<activemodel>.freeze, ["~> 5.0"])
    s.add_dependency(%q<activemodel-serializers-xml>.freeze, ["~> 1.0"])
    s.add_dependency(%q<ammeter>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-rails>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<active_model_serializers>.freeze, ["~> 0.10"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
  end
end
