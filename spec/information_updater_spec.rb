RSpec.describe InformationUpdater do
  let(:app) { App.new }
  # let(:path) { File.dirname(__FILE__) + '/support/data_4000_lines.csv' }
  let(:path) { File.dirname(__FILE__) + '/support/data3_simple.csv' }

  before(:each) do
    InformationUpdater.reset_cache
  end

  context '.call' do
    it 'persists patients to the database' do
      expect { InformationUpdater.call(path) }
        .to change { Patient.all.size }.by_at_least 3

      model_patient_1 = Patient.find_by(cpf: '018.581.237-63')
      expect(model_patient_1.name).to eq 'Ana Beatriz Rios'
      expect(model_patient_1.email).to eq 'ana.b.rios@protonmail.com'
      expect(model_patient_1.birth_date).to eq Date.new(1989, 9, 26)

      model_patient_2 = Patient.find_by(cpf: '037.787.232-60')
      expect(model_patient_2.name).to eq 'João Felipe Louzada'
      expect(model_patient_2.email).to eq 'jlouzada@woohoo.com'
      expect(model_patient_2.birth_date).to eq Date.new(1985, 1, 22)
    end

    it 'persists physicians to the database' do
      expect { InformationUpdater.call(path) }
        .to change { Physician.all.size }.by_at_least 2

      model_physician = Physician.find_by(crm_number: 'B0002W2RBG', crm_state: 'CE')
      expect(model_physician.name).to eq 'Dianna Klein'
    end

    it 'persists lab tests to the database' do
      expect { InformationUpdater.call(path) }
        .to change { Test.all.size }.by_at_least 4

      model_test_1 = Test.find_by(patient_id: Patient.find_by(cpf: '018.581.237-63').id, 
                                  date: '2021-12-01', name: 'hemácias')
      expect(model_test_1.result_range).to eq '45-52'
      expect(model_test_1.result).to eq '25'
      expect(model_test_1.patient.name).to eq 'Ana Beatriz Rios'

      model_test_2 = Test.find_by(patient_id: Patient.find_by(cpf: '037.787.232-60').id, 
                                  date: '2021-09-10', name: 'vldl')
      expect(model_test_2.result_range).to eq '48-72'
      expect(model_test_2.result).to eq '60'
      expect(model_test_2.patient.name).to eq 'João Felipe Louzada'
    end

    it 'persists a test report as a collection of tests' do
      expect { InformationUpdater.call(path) }
      .to change { TestReport.all.size }.by_at_least 3

      model_report_1 = TestReport.find_by(token: 'B2KHO4')
      expect(model_report_1.patient.name).to eq 'Ana Beatriz Rios'
      expect(model_report_1.physician.name).to eq 'Dianna Klein'
      expect(model_report_1.tests.size).to be >= 2
      expect(model_report_1.tests.pluck(:name)).to include 'hemácias'
      expect(model_report_1.tests.pluck(:name)).to include 'leucócitos'

      model_report_2 = TestReport.find_by(token: 'L3VQDE')
      expect(model_report_2.patient.name).to eq 'João Felipe Louzada'
      expect(model_report_2.physician.name).to eq 'Dianna Klein'
      expect(model_report_2.tests.pluck(:name)).to include 'vldl'
    end
  end
end