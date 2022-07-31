require 'csv'

class InformationUpdater
  
  def self.call(path)
    registered_cpfs = Patient.pluck(:cpf)
    
    File.open(path) do |file|

      patient_cpf = 'cpf'
      patient_name = 'nome paciente'
      patient_email = 'email paciente'
      patient_birth_date = 'data nascimento paciente'
      test_report_token = 'token resultado exame'

      CSV.foreach(file, headers: true, col_sep: ';') do |line|
        # check / record patient
        unless registered_cpfs.include?(line[patient_cpf])
          Patient.create!(name: line[patient_name],
                          cpf: line[patient_cpf],
                          email: line[patient_email],
                          birth_date: line[patient_birth_date],
                          )        
          registered_cpfs << line['cpf']
        end
        # check / record physician
        # check / record test results
        # build / update test report
      end
    end
  end
end