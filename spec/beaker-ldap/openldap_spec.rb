module BeakerLDAP

  describe OpenLDAP do
    let(:openldap) { BeakerLDAP::OpenLDAP.new( {} )}

    it 'instantiates without error without any supplied arguments' do
      expect { :openldap}.to_not raise_error
    end

    it 'populates the instance variable for default group attributes' do
      expect(openldap.default_group_attributes).to_not be(nil)
    end

    it 'populates the instance variable for default user attributes' do
      expect(openldap.default_user_attributes).to_not be(nil)
    end
  end
end
