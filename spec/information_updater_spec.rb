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

  context '.create_patients' do
    it 'persists patients to db' do
      data = [
        ["cpf", "nome paciente", "email paciente", "data nascimento paciente", "endereço/rua paciente", "cidade paciente", "estado patiente"], 
        ["018.581.237-63", "Ana Beatriz Rios", "hobert_marquardt@kulas.biz", "1989-09-26", "6425 Rua Emilly Nogueira", "Carnaubal", "Distrito Federal"], 
        ["018.581.237-63", "Ana Beatriz Rios", "hobert_marquardt@kulas.biz", "1989-09-26", "6425 Rua Emilly Nogueira", "Carnaubal", "Distrito Federal"], 
        ["037.787.232-60", "João Felipe Louzada", "clifton_hyatt@koss.biz", "1985-01-22", "s/n Viela Theo Modesto", "Cachoeira dos Índios", "Tocantins"],
      ]
      
      InformationUpdater.create_patients(data)

      expect(Patient.all.size).to be 2
    end

    xit 'does not duplicate patients' do
    end

    xit 'works even if the array contains more data' do
    end
  end
end