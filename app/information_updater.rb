require 'csv'

class InformationUpdater
  
  def self.call(path)
    registered_cpfs = Patient.pluck(:cpf)
    registered_crms = Physician.select(:crm_state, :crm_number).map(&:join)
    registered_tokens = TestReport.pluck(:token)
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
        crm_state = line[physician_crm_state].strip.upcase
        crm_number = line[physician_crm_number].strip.upcase
        full_crm = "#{crm_state}#{crm_number}".freeze
        
        patient_id = (
          if registered_cpfs.include?(line[patient_cpf])
            Patient.find_by(cpf: line[patient_cpf]).id
          else
            registered_cpfs << line['cpf']
            (Patient.create!(name: line[patient_name],
                             cpf: line[patient_cpf],
                             email: line[patient_email],
                             birth_date: line[patient_birth_date],
                            )
            ).id   
          end
        )

        physician_id = (
          if registered_crms.include?(full_crm)
            Physician.find_by(crm_state: crm_state, crm_number: crm_number).id
          else
            registered_crms << full_crm
            (Physician.create!(name: line[physician_name],
                                crm_state: crm_state,
                                crm_number: crm_number,
                              )       
            ).id
          end
        )

        report_id = (
          if registered_tokens.include?(line[test_report_token])
            TestReport.find_by(token: line[test_report_token]).id
          else
            registered_tokens << line[test_report_token]
            (TestReport.create!(token: line[test_report_token],
                                patient_id: patient_id,
                                physician_id: physician_id,
                               )  
            ).id
          end
        )

        new_tests << { patient_id: patient_id,
                       test_report_id: report_id,
                       name: line[test_name],
                       date: line[test_date],
                       result_range: line[test_result_range],
                       result: line[test_result],
                     }
      end

      Test.insert_all(new_tests, record_timestamps: true)
    end
  end
end