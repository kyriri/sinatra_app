require 'csv'

class InformationUpdater
  
  def self.call(path)
    registered_cpfs = Patient.pluck(:cpf)
    new_physicians = []
    new_tests = []
    
    File.open(path) do |file|

      patient_cpf = 'cpf'
      patient_name = 'nome paciente'
      patient_email = 'email paciente'
      patient_birth_date = 'data nascimento paciente'

      physician_name = 'nome médico'
      physician_crm_number = 'crm médico'
      physician_crm_state = 'crm médico estado'

      test_name = 'tipo exame'
      test_date = 'data exame'
      test_result_range = 'limites tipo exame'
      test_result = 'resultado tipo exame'

      test_report_token = 'token resultado exame'

      CSV.foreach(file, headers: true, col_sep: ';') do |line|
        
        unless registered_cpfs.include?(line[patient_cpf])
          Patient.create!(name: line[patient_name],
                          cpf: line[patient_cpf],
                          email: line[patient_email],
                          birth_date: line[patient_birth_date],
                          )        
          registered_cpfs << line['cpf']
        end

        # the db has an index called 'by_crm_state_number' which guarantees that
        # the combination of CRM state + CRM number is unique. Duplicates are 
        # skipped by the method Physician.insert_all called later.
        new_physicians << { name: line[physician_name],
                            crm_state: line[physician_crm_state],
                            crm_number: line[physician_crm_number],
                          }       

        # check / record test results
        new_tests << { patient_id: Patient.find_by(cpf: line[patient_cpf]).id,
                       name: line[test_name],
                       date: line[test_date],
                       result_range: line[test_result_range],
                       result: line[test_result],
                     }

        # build / update test report
      end
      Physician.insert_all(new_physicians, record_timestamps: true)
      Test.insert_all(new_tests, record_timestamps: true)
    end
  end
end