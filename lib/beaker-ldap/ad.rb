module BeakerLDAP
  class AD < BeakerLDAP::LDAP
    def initialize(options)
      super options
      @default_user_attributes = {:objectClass => ['top',
                                                   'person',
                                                   'organizationalPerson',
                                                   'inetOrgPerson'],
                                  :userAccountControl => ['544']}
      @default_group_attributes = ['top','group']
    end

    # This is used to encode passwords for Windows AD
    # See URL: http://msdn.microsoft.com/en-us/library/cc223248.aspx
    def str_to_unicode_pwd(str)
      ('"' + str + '"').encode("utf-16le").force_encoding("utf-8")
    end

    def update_user_password(user_dn, password)
      password = str_to_unicode_pwd(password)
      super(user_dn,password)
    end
  end
end
