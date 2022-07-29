RSpec.describe InformationUpdater do
  let(:app) { App.new }

  context '.read' do
    it 'reads CSV files and transforms them into arrays' do
      path = File.dirname(__FILE__) + '/support/data3_simple.csv'
  
      response = InformationUpdater.read(path)
  
      expect(response).to be_an Array
      expect(response[0]).to include 'nome paciente'
      expect(response[0]).to include 'email paciente'
    end
  end
end