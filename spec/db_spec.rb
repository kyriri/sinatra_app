RSpec.describe 'Testing database' do
  let(:app) { App.new }

  it 'is correctly wired' do
    database_in_use = ActiveRecord::Base.connection_db_config.database

    expect(database_in_use).to include 'test' # as opposed to development or production
  end

  it 'accepts records' do
    Patient.create(name: 'Johnny Bravo')

    expect(Patient.last.name).to eq 'Johnny Bravo'
  end

  context 'is used many times' do
    2.times do |iteration|
      it "and starts empty on run # #{iteration + 1}" do
        Patient.create(name: 'Powerpuff Girls')
    
        expect(Patient.count).to be 1
      end
    end
  end
end