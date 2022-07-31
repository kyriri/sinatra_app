RSpec.describe InformationUpdater do
  let(:app) { App.new }

  context '.call' do
    it 'persists patients to the database' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'

      InformationUpdater.call(path)

      expect(Patient.all.size).to be 2
      
      expect(Patient.first.cpf).to eq '018.581.237-63'
      expect(Patient.first.name).to eq 'Ana Beatriz Rios'
      expect(Patient.first.email).to eq 'ana.b.rios@protonmail.com'
      expect(Patient.first.birth_date).to eq Date.new(1989, 9, 26)

      expect(Patient.last.cpf).to eq '037.787.232-60'
      expect(Patient.last.name).to eq 'João Felipe Louzada'
      expect(Patient.last.email).to eq 'jlouzada@woohoo.com'
      expect(Patient.last.birth_date).to eq Date.new(1985, 1, 22)
    end

    it 'persists physicians to the database' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'

      InformationUpdater.call(path)

      expect(Physician.all.size).to be 1
      expect(Physician.last.crm_number).to eq 'B0002W2RBG'
      expect(Physician.last.crm_state).to eq 'CE'
      expect(Physician.last.name).to eq 'Diann Klein'
    end
  end
end