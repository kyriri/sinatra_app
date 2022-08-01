RSpec.describe Physician do
  let(:app) { App.new }

  context 'CRM registration' do
    it 'allows repetition of CRM state' do
      create(:physician, crm_state: 'CE', crm_number: '443')
      
      create(:physician, crm_state: 'CE', crm_number: '1021') 

      expect(Physician.last.crm_state).to eq 'CE'
      expect(Physician.last.crm_number).to eq '1021'
    end

    it 'allows repetition of CRM number' do
      create(:physician, crm_state: 'CE', crm_number: '443')
      
      create(:physician, crm_state: 'AC', crm_number: '443') 

      expect(Physician.last.crm_state).to eq 'AC'
      expect(Physician.last.crm_number).to eq '443'
    end

    it 'blocks repetition of full CRM (state + number)' do
      create(:physician, crm_state: 'CE', crm_number: '1021')
      
      expect { create(:physician, crm_state: 'CE', crm_number: '1021') }
        .to raise_error ActiveRecord::RecordNotUnique
    end
  end
end