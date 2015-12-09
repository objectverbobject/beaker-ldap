if ENV['BEAKER_LDAP_COVERAGE']
  require 'simplecov'
  SimpleCov.start
end
require 'beaker-ldap'