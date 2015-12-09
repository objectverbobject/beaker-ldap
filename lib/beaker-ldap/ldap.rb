module BeakerLDAP
  class << self
    def new(options)
      validate_options(options)
      case determine_ds_type(options)
        when :openldap
          return BeakerLDAP::OpenLDAP.new(options)
        when :active_directory
          return BeakerLDAP::AD.new(options)
      end
    end

    def validate_options(options)
      [:base, :auth, :host].each do |required_option|
        raise "Missing required option #{required_option}" if options[required_option].nil?
      end
    end

    def determine_ds_type(options)
      ds = Net::LDAP.new(options)
      if !ds.bind
        raise 'unable to bind, check your credentials and server parameters'
      end
      ff = ds.search(:ignore_server_caps => true,
                      :base               => '',
                      :attributes         => ['forestFunctionality'],
                      :scope              => Net::LDAP::SearchScope_BaseObject)[0][:forestfunctionality]

      return :openldap if ff.empty?
      :active_directory
    end
  end

  class LDAP < Net::LDAP
    attr_accessor :test_uid
    attr_reader :top_ou_test_fixtures,
                :default_user_attributes,
                :default_group_attributes

    def initialize(options)
      super options
      # Generate a random 4 character string (e.g. 3Ph4), excludes 0/1/I/O/l.
      @test_uid             = ([*('A'..'Z'), *('0'..'9'), *('a'..'z')]-%w(0 1 I O l)).sample(4).join

      # initialize the :top_ou_list as an empty array
      @top_ou_test_fixtures = []
    end

    def auth_details
      @auth
    end

    def create_top_ou(name)
      ou   = name + @test_uid
      dn   = "ou=#{ou},#{self.base}"
      attr = { :objectClass => ['top', 'organizationalUnit'],
               :ou          => ou }
      add(:dn => dn, :attributes => attr)
      if get_operation_result.code != 0
        raise "OU creation failed: #{get_operation_result}, #{dn}"
      end
      @top_ou_test_fixtures.push dn
    end

    def delete_all_top_ou_test_fixtures
      @top_ou_test_fixtures.each do |ou|
        delete_all_entries_containing_rdn(ou)
      end
    end

    def delete_all_entries_containing_rdn(rdn)
      entries = search(:base => rdn, :attributes => ['dn'])
      if entries.empty?
        warn "no entries found for #{rdn}"
        return
      end
      entries.each do |entry|
        delete :dn => entry.dn
      end

      #This needs to be repeated because it may have failed deleting a group
      #that still had users associated.
      entries.each do |entry|
        delete :dn => entry.dn
      end

      #This request should return nil; all entities with the dn provided
      #should now be deleted.
      entries = search(:base => rdn, :attributes => ['dn'])
      if entries != nil
        raise "Problem deleting all entries for this dn: #{rdn}"
      end
    end

    def create_ds_user(attributes, rdn)
      raise ArgumentError, 'attributes argument must supply the :cn key' if attributes[:cn].nil?
      merged_attributes = default_user_attributes.merge(attributes)

      add(:dn         => "cn=#{merged_attributes[:cn]},#{rdn}",
          :attributes => merged_attributes)

      if get_operation_result.code != 0
        raise "Creating user failed: #{get_operation_result}\n
              #{merged_attributes}"
      end
    end

    def create_ds_group(attributes, rdn)
      raise ArgumentError, 'attributes argument must supply the :cn key' if attributes[:cn].nil?
      merged_attributes = default_group_attributes.merge(attributes)

      add(:dn         => "cn=#{merged_attributes[:cn]},#{rdn}",
          :attributes => merged_attributes)

      if get_operation_result.code != 0
        raise "Creating group failed: #{get_operation_result},\n
              #{merged_attributes}"
      end
    end

    def update_user_password(user_dn, password)
      ops = [[:replace, :userPassword, password]]

      modify :dn => user_dn, :operations => ops

      if get_operation_result.code != 0
        raise "Updating password failed: #{get_operation_result}\n
              #{ops}"
      end
    end
  end
end
