# component tests for InformationUpdater 
# check, implicity or explicity, the behavior of  
# two or more InformationUpdater methods

RSpec.describe InformationUpdater do
  let(:app) { App.new }

  before(:each) do
    InformationUpdater.reset_cache
  end

  context '.id_finder' do
    it 'causes record creation when item is not in cache' do
      create(:physician, crm_state: 'es', crm_number: '534')
      create(:physician, crm_state: 'mg', crm_number: '2849n')
      attrs = {
        name: 'Margaret Ann Bulkley', 
        crm_state: 'mt',
        crm_number: '9f48a',
      } 

      result = InformationUpdater.id_finder(type: 'physician', keys: ['mt', '9f48a'], attrs: attrs)

      expect(result).to eq Physician.last.id
      expect(Physician.last.crm_number).to eq '9F48A'
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
end