# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beaker-ldap/version'

Gem::Specification.new do |spec|
  spec.name          = 'beaker-ldap'
  spec.version       = BeakerLDAP::Version::STRING
  spec.authors       = ['Tony Vu']
  spec.email         = ['qa@puppetlabs.com']
  spec.summary       = 'Puppetlabs testing tool for LDAP'
  spec.description   = <<-eos
This beaker-ldap tool is used to configure and teardown LDAP users and groups
for testing purposes. It is also used by the beaker-http library to help
configure RBAC with an external directory service.
  eos
  spec.homepage      = 'https://github.com/puppetlabs/beaker-ldap'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #Development dependencies
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry', '~> 0.9.12'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'

  #Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0'
  spec.add_development_dependency 'markdown', '~> 0'

  #Run time dependencies
  spec.add_runtime_dependency 'net-ldap', '~> 0.6', '>= 0.6.1'
end
