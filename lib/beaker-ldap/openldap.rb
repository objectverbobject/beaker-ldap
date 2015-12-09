module BeakerLDAP
  class OpenLDAP < BeakerLDAP::LDAP
    def initialize(options)
      super(options)
      @default_user_attributes = {:objectClass => ['top',
                                                   'person',
                                                   'organizationalPerson',
                                                   'inetOrgPerson']}
      @default_group_attributes = ['top','groupOfUniqueNames']

    end
  end
end
