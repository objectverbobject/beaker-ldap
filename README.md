# beaker-ldap

##### Table of Contents
1. [Overview](#Overview)
2. [Usage](#Usage)
3. [Support](#Support)

## Overview

The gem `beaker-ldap` is a tool that extends the 
[Net::LDAP](https://github.com/ruby-ldap/ruby-net-ldap) gem to assist in 
generating environments for testing with a directory service. Specifically, 
it supports openldap and Microsoft Active Directory.

## Usage

Install the gem from http://rubygems.org:
```
$ gem install beaker-ldap
```
In your ruby code, use the `BeakerLDAP.new` method to instantiate a new
object to communicate with your directory service. The options required—`host`, 
`base`, and `auth`—are used to test binding to the ds and then do a simple 
search for `forestFunctionality` in the root DSE to determine if the directory 
service is OpenLDAP or Active Directory.

```ruby
require 'beaker-ldap'
options = { :host => 'ds.example.com',
            :base => 'dc=example,dc=com',
            :auth => { :method => :simple, 
                       :username => 'cn=admin,dc=example,dc=com',
                       :password => 'sekritpa$$word' }
          }
directory_service = BeakerLDAP.new(options)
```
While `host`, `base`, and `auth` are required keys, it is also likely you will
want to set other settings as well, notably `encryption` and `port`. Please 
review the [Net::LDAP](https://github.com/ruby-ldap/ruby-net-ldap) documentation
for further documentation on what can be passed as in the `options` parameter.
## Support
The gem `beaker-ldap` is supported by Puppetlabs and used for internal testing. 
If you have questions or comments, please direct them to the Beaker team at
`#puppet-dev` IRC channel on chat.freenode.org.
