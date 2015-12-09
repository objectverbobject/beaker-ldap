module BeakerLDAP
  describe LDAP do
    let(:ldap) { BeakerLDAP::LDAP.new({}) }

    it 'allows creation without subclassing' do
      expect { :ldap }.to_not raise_error
    end

    it 'creates a test_uid after initialization' do
      expect(ldap.test_uid.class).to be(String)
    end

    it 'initializes an empty array for storage of top level organizational units' do
      expect(ldap.top_ou_test_fixtures).to be_empty
    end

    describe '#auth_details' do
      it 'defaults to the Net::LDAP value when no :auth key is present during initialization' do
        expect(ldap.auth_details).to eq(Net::LDAP::DefaultAuth)
      end

      it 'returns the values set in the auth method' do
        ldap.auth('username', 'password')
        expect(ldap.auth_details).to include(username: 'username', password: 'password')
      end
    end

    describe '#create_top_ou' do
      it 'raises an argument error without a supplied name' do
        expect { ldap.create_top_ou }.to raise_error(ArgumentError)
      end
      it 'raises an error if the result code was not 0' do
        allow(ldap).to receive(:add)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 1))
        expect { ldap.create_top_ou('name') }.to raise_error(RuntimeError)
      end
      it 'appends to the list of test ou\'s if successful' do
        allow(ldap).to receive(:add)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 0))
        ldap.create_top_ou('name')
        ldap.create_top_ou('second_name')
        expect(ldap.top_ou_test_fixtures).to include("ou=name#{ldap.test_uid},#{ldap.base}",
                                                     "ou=second_name#{ldap.test_uid},#{ldap.base}")
      end
    end

    describe '#delete_all_top_ou_test_fixtures' do
      it 'attempts to delete all entries listed in the top ou list' do
        ldap.instance_variable_set('@top_ou_test_fixtures', [1,2])
        expect(ldap).to receive(:delete_all_entries_containing_rdn).with(1).once
        expect(ldap).to receive(:delete_all_entries_containing_rdn).with(2).once
        expect{ldap.delete_all_top_ou_test_fixtures}.to_not raise_error
      end
    end

    describe '#delete_all_entries_containing_rdn' do
      it 'calls search only once if no entries are found containing rdn' do
        expect(ldap).to receive(:search).once.and_return([])
        expect { ldap.delete_all_entries_containing_rdn('rdn') }.to_not raise_error
      end
      describe 'when search returns a result not nil' do
        it 'succeeds when the second search returns nil' do
          mock_result1  = Object.new
          mock_result2  = Object.new
          search_result = [mock_result1, mock_result2]
          allow(mock_result1).to receive(:dn).and_return('mock_result')
          allow(mock_result2).to receive(:dn).and_return('mock_result')
          allow(ldap).to receive(:search).and_return(search_result, nil)
          expect(ldap).to receive(:delete).with(dn: 'mock_result').at_least(4).times
          expect(ldap.delete_all_entries_containing_rdn('rdn')).to be_nil
        end
        it 'fails when the second search returns a found entry' do
          mock_result1  = Object.new
          mock_result2  = Object.new
          search_result = [mock_result1, mock_result2]
          allow(mock_result1).to receive(:dn).and_return('mock_result')
          allow(mock_result2).to receive(:dn).and_return('mock_result')
          allow(ldap).to receive(:search).and_return(search_result, search_result)
          expect(ldap).to receive(:delete).with(dn: 'mock_result').at_least(4).times
          expect{ldap.delete_all_entries_containing_rdn('rdn')}.to raise_error(RuntimeError)
        end
      end
    end

    describe '#create_ds_user' do
      let(:default_user_attributes) { { objectClass: ['person'] } }
      it ' raises an argument error with the wrong number of arguments' do
        expect { ldap.create_ds_user }.to raise_error(ArgumentError)
        expect { ldap.create_ds_user(1, 2, 3) }.to raise_error(ArgumentError)
      end
      it 'raises an argument error when missing the :cn key in the attributes hash' do
        expect { ldap.create_ds_user({ no_cn: 'nocn' }, 'rdn') }.to raise_error(ArgumentError)
      end
      it 'raises a runtime error when the result code is non zero' do
        allow(ldap).to receive(:default_user_attributes).and_return(default_user_attributes)
        allow(ldap).to receive(:add)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 1))
        expect { ldap.create_ds_user({ cn: 'cn' }, 'rdn') }.to raise_error(RuntimeError)
      end
      it 'succeeds without error when the result code is 0' do
        allow(ldap).to receive(:default_user_attributes).and_return(default_user_attributes)
        allow(ldap).to receive(:add)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 0))
        expect { ldap.create_ds_user({ cn: 'cn' }, 'rdn') }.to_not raise_error
      end
    end

    describe '#create_ds_group' do
      let(:default_group_attributes) { { objectClass: ['group'] } }
      it ' raises an argument error with the wrong number of arguments' do
        expect { ldap.create_ds_group }.to raise_error(ArgumentError)
        expect { ldap.create_ds_group(1, 2, 3) }.to raise_error(ArgumentError)
      end
      it 'raises an argument error when missing the :cn key in the attributes hash' do
        expect { ldap.create_ds_group({ no_cn: 'nocn' }, 'rdn') }.to raise_error(ArgumentError)
      end
      it 'raises a runtime error when the result code is non zero' do
        allow(ldap).to receive(:default_group_attributes).and_return(default_group_attributes)
        allow(ldap).to receive(:add)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 1))
        expect { ldap.create_ds_group({ cn: 'cn' }, 'rdn') }.to raise_error(RuntimeError)
      end
      it 'succeeds without error when the result code is 0' do
        allow(ldap).to receive(:default_group_attributes).and_return(default_group_attributes)
        allow(ldap).to receive(:add)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 0))
        expect { ldap.create_ds_group({ cn: 'cn' }, 'rdn') }.to_not raise_error
      end
    end

    describe '#update_user_password' do
      let(:default_group_attributes) { { objectClass: ['group'] } }
      it ' raises an argument error with the wrong number of arguments' do
        expect { ldap.update_user_password }.to raise_error(ArgumentError)
        expect { ldap.update_user_password(1, 2, 3) }.to raise_error(ArgumentError)
      end
      it 'raises a runtime error when the result code is non zero' do
        allow(ldap).to receive(:modify)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 1))
        expect { ldap.update_user_password('userdn', 'password') }.to raise_error(RuntimeError)
      end
      it 'succeeds without error when the result code is 0' do
        allow(ldap).to receive(:modify)
        allow(ldap).to receive(:get_operation_result).and_return(OpenStruct.new(:code => 0))
        expect { ldap.update_user_password('userdn', 'password') }.to_not raise_error
      end
    end
  end

  describe BeakerLDAP do

    describe '#new' do
      it 'returns a Beaker OpenLDAP object when it determines the ds is Openldap' do
        allow(BeakerLDAP).to receive(:validate_options)
        allow(BeakerLDAP).to receive(:determine_ds_type).and_return(:openldap)
        expect(BeakerLDAP.new({}).class).to match(BeakerLDAP::OpenLDAP)
      end
      it 'returns a Beaker AD object when it determines the ds is Active Directory' do
        allow(BeakerLDAP).to receive(:validate_options)
        allow(BeakerLDAP).to receive(:determine_ds_type).and_return(:active_directory)
        expect(BeakerLDAP.new({}).class).to match(BeakerLDAP::AD)
      end
    end

    describe '#validate_options' do
      context 'Ensure this raises errors when missing required keys' do
        describe 'Missing :base key' do
          let(:options) { { :auth => 'auth', :host => 'host' } }
          it 'raises an error' do
            expect { BeakerLDAP.validate_options(options) }.to raise_error(RuntimeError, /Missing required option base/)
          end
        end
        describe 'Missing :auth key' do
          let(:options) { { :base => 'base', :host => 'host' } }
          it 'raises an error' do
            expect { BeakerLDAP.validate_options(options) }.to raise_error(RuntimeError, /Missing required option auth/)
          end
        end
        describe 'Missing :host key' do
          let(:options) { { :base => 'base', :auth => 'auth' } }
          it 'raises an error' do
            expect { BeakerLDAP.validate_options(options) }.to raise_error(RuntimeError, /Missing required option host/)
          end
        end
      end
      context 'Ensure extra keys are allowed' do
        let(:options) { { :base      => 'base',
                          :auth      => 'auth',
                          :host      => 'host',
                          :extra_key => 'extra key' } }
        it 'does not raise an error' do
          expect { BeakerLDAP.validate_options(options) }.to_not raise_error
        end
      end
    end

    describe '#determine_ds_type' do
      mock_ldap          = Object.new
      mock_ldap_response = Net::LDAP::Entry.new('')
      it 'raises an exception when bind fails' do
        allow(Net::LDAP).to receive(:new).and_return(mock_ldap)
        allow(mock_ldap).to receive(:bind).and_return(false)
        expect { BeakerLDAP.determine_ds_type({}) }.to raise_error(RuntimeError)
      end
      it 'returns :openldap when it finds nothing in the search' do
        allow(Net::LDAP).to receive(:new).and_return(mock_ldap)
        allow(mock_ldap).to receive(:bind).and_return(true)
        allow(mock_ldap).to receive(:search).and_return([mock_ldap_response])
        expect(BeakerLDAP.determine_ds_type({})).to eq(:openldap)
      end
      it 'returns :active_directory when it finds forestfunctionality' do
        mock_ldap_response['forestfunctionality'] = '5'
        allow(Net::LDAP).to receive(:new).and_return(mock_ldap)
        allow(mock_ldap).to receive(:bind).and_return(true)
        allow(mock_ldap).to receive(:search).and_return([mock_ldap_response])
        expect(BeakerLDAP.determine_ds_type({})).to eq(:active_directory)
      end
    end
  end
end
