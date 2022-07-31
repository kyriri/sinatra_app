require 'csv'

class InformationUpdater
  
  def self.call(path)

    cached_patient_ids = 
      Patient.select(:id, :cpf).each_with_object({}) do |record, cache|
        cache.store(record.cpf.to_sym, record.id)
      end

    cached_physician_ids = 
      Physician.select(:id, :crm_state, :crm_number).each_with_object({}) do |record, cache|
        cache.store("#{record.crm_state}#{record.crm_number}".to_sym, record.id)
      end

    cached_report_ids = 
        TestReport.select(:id, :token).each_with_object({}) do |record, cache|
          cache.store(record.token.to_sym, record.id)
        end

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

        patient_id = (
          if cached_patient_ids.has_key?(line[patient_cpf].to_sym)
            cached_patient_ids[line[patient_cpf].to_sym]
          else
            new_id = (Patient.create!(name: line[patient_name],
                                      cpf: line[patient_cpf],
                                      email: line[patient_email],
                                      birth_date: line[patient_birth_date])
                     ).id 
            cached_patient_ids.store(line[patient_cpf].to_sym, new_id)
            new_id
          end
        )

        crm_state = line[physician_crm_state].strip.upcase
        crm_number = line[physician_crm_number].strip.upcase
        full_crm = "#{crm_state}#{crm_number}".to_sym
        physician_id = (
          if cached_physician_ids.has_key?(full_crm)
            cached_physician_ids[full_crm]
          else
            new_id = (Physician.create!(name: line[physician_name],
                                        crm_state: crm_state,
                                        crm_number: crm_number)
                     ).id 
            cached_physician_ids.store(full_crm, new_id)
            new_id
          end
        )

        cached_report_ids
        report_id = (
          if cached_report_ids.has_key?(line[test_report_token].to_sym)
            cached_report_ids[line[test_report_token].to_sym]
          else
            patient_id
            new_id = (TestReport.create!(token: line[test_report_token],
                                          patient_id: patient_id,
                                          physician_id: physician_id)  
                     ).id
            cached_report_ids.store(line[test_report_token].to_sym, new_id)
            new_id
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