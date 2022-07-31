RSpec.describe Patient do
  let(:app) { App.new }

  context '#cpf' do
    it 'should be checked for uniquess by ActiveRecord' do
      create(:patient, cpf: '615.996.385-68')
      duplicate = build(:patient, cpf: '615.996.385-68')
      
      duplicate.valid?

      expect(duplicate.errors.of_kind?(:cpf, :taken)).to be_truthy
    end

    it 'should be checked for uniquess by the DB' do
      create(:patient, cpf: '615.996.385-68')
      
      expect { 
        # this is an indirect test: insert_all skips ActiveRecord validations,
        # but the records won't be saved if they violate any DB constraint 
        Patient.insert_all([{ cpf: '615.996.385-68' }], record_timestamps: true)
      }.not_to change { Patient.all.size }
    end
  end
end