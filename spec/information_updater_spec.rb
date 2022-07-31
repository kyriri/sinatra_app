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

    it 'persists lab tests to the database' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'

      InformationUpdater.call(path)

      expect(Test.all.size).to be 3

      expect(Test.first.date).to eq Date.new(2021, 12, 1)
      expect(Test.first.name).to eq 'hemácias'
      expect(Test.first.result_range).to eq '45-52'
      expect(Test.first.result).to eq '25'
      expect(Test.first.patient.name).to eq 'Ana Beatriz Rios'
      expect(Test.first.patient.cpf).to eq '018.581.237-63'

      expect(Test.last.date).to eq Date.new(2021, 9, 10)
      expect(Test.last.name).to eq 'vldl'
      expect(Test.last.result_range).to eq '48-72'
      expect(Test.last.result).to eq '60'
      expect(Test.last.patient.name).to eq 'João Felipe Louzada'
      expect(Test.last.patient.cpf).to eq '037.787.232-60'
    end
  end
end