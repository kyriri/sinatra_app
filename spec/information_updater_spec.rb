RSpec.describe InformationUpdater do
  let(:app) { App.new }

  before(:each) do
    InformationUpdater.reset_cache
  end

  context '.retrieve_cache_group' do
    it 'builds cache using simple key' do
      ['540.772.581-97', '184.606.175-05', '615.996.385-68'].each { |cpf| create(:patient, cpf: cpf) } 
      
      cached_patient_ids = InformationUpdater.retrieve_cache_group(type: 'patient', keys: [:cpf])

      expect(cached_patient_ids).to be_a Hash
      expect(cached_patient_ids.first[0]).to be_a Symbol   # key
      expect(cached_patient_ids.first[1]).to be_an Integer # value

      expect(cached_patient_ids.size).to be 3
      expect(cached_patient_ids['184.606.175-05'.to_sym]).to eq Patient.find_by(cpf: '184.606.175-05').id
    end

    it 'builds cache using composite key' do
      create(:physician, crm_state: 'AL', crm_number: '3852')
      create(:physician, crm_state: 'RR', crm_number: '455')
      
      cached_physician_ids = InformationUpdater.retrieve_cache_group(type: 'physician', keys: [:crm_state, :crm_number])

      expect(cached_physician_ids).to be_a Hash
      expect(cached_physician_ids.first[0]).to be_a Symbol   # key
      expect(cached_physician_ids.first[1]).to be_an Integer # value

      expect(cached_physician_ids.size).to be 2
      expect(cached_physician_ids['AL3852'.to_sym]).to eq Physician.find_by(crm_state: 'AL', crm_number: '3852').id
    end

    it 'can handle multi-word types' do
      create(:test_report, token: 'JH9876G')
      create(:test_report, token: 'L08EHV8')
      
      cached_reports_ids = InformationUpdater.retrieve_cache_group(type: 'test_report', keys: [:token])

      expect(cached_reports_ids.size).to be 2
      expect(cached_reports_ids['L08EHV8'.to_sym]).to eq TestReport.find_by(token: 'L08EHV8').id
     end

    it 'raises exception if the table is not known' do
      expect { 
        InformationUpdater.retrieve_cache_group(type: 'happiness', keys: [:chocolate, :ice_cream]) 
      }.to raise_error InvalidTypeError
    end

  end

  context '.build_cache' do
    it 'builds cache object' do
      5.times { create(:patient) }
      2.times { create(:physician) }
      8.times { create(:test_report) }

      cache = InformationUpdater.build_cache

      expect(cache.keys).to eq [:patients, :physicians, :test_reports]
      cache.values.each { |v| expect(v).to be_a Hash }

      expect(cache[:patients].size).to be 5
      expect(cache[:physicians].size).to be 2
      expect(cache[:test_reports].size).to be 8
    end

    it 'builds cache object even if database is empty' do
      cache = InformationUpdater.build_cache

      expect(cache.keys).to eq [:patients, :physicians, :test_reports]
      cache.values.each { |v| expect(v).to be_a Hash }

      expect(cache[:patients]).to be_empty
      expect(cache[:physicians]).to be_empty
      expect(cache[:test_reports]).to be_empty
    end
  end

  context '.create_record' do
  let(:whitespace) { ['', ' ', "\n", "\t", "\r"] }

    it 'knows how to create a Patient' do
      attrs = {
        name: whitespace.sample + 'Salomea Skłodowska' + whitespace.sample, 
        cpf: whitespace.sample  + '014.274.111-66'   + whitespace.sample,
        birth_date: whitespace.sample + '1967-11-07' + whitespace.sample,
        email: whitespace.sample + 'salomea@irsn.fr' + whitespace.sample,
      } 

      response = InformationUpdater.create_record('patient', attrs)

      expect(Patient.last.name).to eq 'Salomea Skłodowska'
      expect(Patient.last.cpf).to eq '014.274.111-66'
      expect(Patient.last.birth_date).to eq Date.new(1967, 11, 7)
      expect(Patient.last.email).to eq 'salomea@irsn.fr'
      expect(response).to be Patient.last.id
    end

    it 'knows how to create a Physician' do
      attrs = {
        name: whitespace.sample + 'Margaret Ann Bulkley' + whitespace.sample, 
        crm_state: whitespace.sample + 'mt' + whitespace.sample,
        crm_number: whitespace.sample + '9f48a' + whitespace.sample,
      } 

      response = InformationUpdater.create_record('physician', attrs)

      expect(Physician.last.name).to eq 'Margaret Ann Bulkley'
      expect(Physician.last.crm_state).to eq 'MT'
      expect(Physician.last.crm_number).to eq '9F48A'
      expect(response).to be Physician.last.id
    end

    it 'knows how to create a Test Report' do
      patient = create(:patient)
      physician = create(:physician)
      attrs = {
        token: whitespace.sample + 'Gg45_p98' + whitespace.sample,
        patient_id: patient.id, 
        physician_id: physician.id,
      } 

      response = InformationUpdater.create_record('test_report', attrs)

      expect(TestReport.last.token).to eq 'Gg45_p98'
      expect(TestReport.last.patient).to eq patient
      expect(TestReport.last.physician).to eq physician
      expect(response).to be TestReport.last.id
    end

    it 'knows how to create a test' do
      patient = create(:patient)
      test_report = create(:test_report)
      attrs = {
        name: whitespace.sample + 'red cells count' + whitespace.sample,
        date: whitespace.sample + '2019-05-11' + whitespace.sample,
        result_range: whitespace.sample + '30-120' + whitespace.sample,
        result: whitespace.sample + '55' + whitespace.sample,
        patient_id: patient.id, 
        test_report_id: test_report.id,
      } 

      response = InformationUpdater.create_record('test', attrs)

      expect(Test.last.name).to eq 'red cells count'
      expect(Test.last.date).to eq Date.new(2019, 5, 11)
      expect(Test.last.result_range).to eq '30-120'
      expect(Test.last.result).to eq '55'
      expect(Test.last.patient).to eq patient
      expect(Test.last.test_report).to eq test_report
      expect(response).to be Test.last.id
    end

    it 'raises an error for other types' do
      attrs = {
        type: 'ski',
        destination: 'Aspen', 
      } 

      expect { InformationUpdater.create_record('dream_vacation', attrs) }
        .to raise_error InvalidTypeError
    end
  end


  context '.id_finder' do
    it 'returns id when the item was cached' do
      create(:test_report, token: 'P9_H8E')
      report = create(:test_report, token: 'H78LO6F')

      result = InformationUpdater.id_finder(type: 'test_report', keys: ['H78LO6F'], args: {})

      expect(result).to be report.id
    end

    it 'can handle composite keys' do
      create(:physician, crm_state: 'AC', crm_number: '2209')
      physician = create(:physician, crm_state: 'KE', crm_number: '875L')

      result = InformationUpdater.id_finder(type: 'physician', keys: ['KE', '875L'], args: {})

      expect(result).to be physician.id
    end

    it 'invokes record creation and updates cache when item was not cached' do
      allow(InformationUpdater).to receive(:create_record).and_return('creation was invoked')
      create(:patient, cpf: '143.534.138-83')
      create(:patient, cpf: '084.293.248-09')

      result = InformationUpdater.id_finder(type: 'patient', keys: ['014.274.111-66'], args: {})

      expect(result).to eq 'creation was invoked'
      expect(InformationUpdater.cache[:patients]).to have_key '014.274.111-66'.to_sym

    end

    it 'raises an error if type is unknown' do
      expect { InformationUpdater.id_finder(type: 'life_meaning', keys: ['3.14'], args: {})}
        .to raise_error InvalidTypeError
    end
  end

  context '.call' do
    it 'persists patients to the database' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'

      InformationUpdater.call(path)

      expect(Patient.all.size).to be 3
      
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

      expect(Physician.all.size).to be 2
      expect(Physician.first.crm_number).to eq 'B0002W2RBG'
      expect(Physician.first.crm_state).to eq 'CE'
      expect(Physician.first.name).to eq 'Dianna Klein'
    end

    it 'persists lab tests to the database' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'

      InformationUpdater.call(path)

      expect(Test.all.size).to be 4

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

    it 'persists a test report as a collection of tests' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'

      InformationUpdater.call(path)

      expect(TestReport.all.size).to be 3
      expect(TestReport.first.token).to eq 'B2KHO4'
      expect(TestReport.first.patient.name).to eq 'Ana Beatriz Rios'
      expect(TestReport.first.physician.name).to eq 'Dianna Klein'
      expect(TestReport.first.tests.size).to be 2
      expect(TestReport.first.tests.first.name).to eq 'hemácias'
      expect(TestReport.first.tests.last.name).to eq 'leucócitos'

      expect(TestReport.last.token).to eq 'L3VQDE'
      expect(TestReport.last.patient.name).to eq 'João Felipe Louzada'
      expect(TestReport.last.physician.name).to eq 'Dianna Klein'
      expect(TestReport.last.tests.first.name).to eq 'vldl'
    end
  end
end