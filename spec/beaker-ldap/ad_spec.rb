module BeakerLDAP

  describe AD do
    let(:ad) { BeakerLDAP::AD.new({}) }
    unicodepwd = "\"\u0000p\u0000a\u0000s\u0000s\u0000w\u0000o\u0000r\u0000d\u0000\"\u0000"

    it 'instantiates without error without any supplied arguments' do
      expect { :ad }.to_not raise_error
    end

    it 'populates the instance variable for default group attributes' do
      expect(ad.default_group_attributes).to_not be(nil)
    end

    it 'populates the instance variable for default user attributes' do
      expect(ad.default_user_attributes).to_not be(nil)
    end

    describe '#str_to_unicode_pwd' do
      it 'converts plain text strings to unicode' do
        expect(ad.str_to_unicode_pwd('password')).to eq(unicodepwd)
      end
    end

    it 'converts a plain text password into a unicodePwd before trying to update it' do
      expect_any_instance_of(BeakerLDAP::LDAP).to receive(:update_user_password).with('user_rdn', unicodepwd).and_return('super_called')
      expect(ad).to receive(:str_to_unicode_pwd).with('password').and_return(unicodepwd)
      expect(ad.update_user_password('user_rdn', 'password')).to eq('super_called')
    end
  end
end
