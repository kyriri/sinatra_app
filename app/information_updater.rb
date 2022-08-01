require 'csv'

class InvalidTypeError < StandardError
end

class InformationUpdater
  
  PATIENT_CPF = 'cpf'
  PATIENT_NAME = 'nome paciente'
  PATIENT_EMAIL = 'email paciente'
  PATIENT_BIRTH_DATE = 'data nascimento paciente'

  PHYSICIAN_NAME = 'nome médico'
  PHYSICIAN_CRM_NUMBER = 'crm médico'
  PHYSICIAN_CRM_STATE = 'crm médico estado'

  TEST_NAME = 'tipo exame'
  TEST_DATE = 'data exame'
  TEST_RESULT_RANGE = 'limites tipo exame'
  TEST_RESULT = 'resultado tipo exame'

  REPORT_TOKEN = 'token resultado exame'

  @@cache = nil

  def self.cache
    @@cache
  end

  def self.retrieve_cache_group(type:, keys:)
    sanitized_type = type.split('_').map(&:capitalize).join
    Object.const_get(sanitized_type) # yields model name, ex: Patient
          .select(:id, *keys)
          .each_with_object({}) do |record, cache|
            cache_key = keys.map { |key| record[key] }.join.to_sym
            cache.store(cache_key, record.id)
          end
  rescue NameError
    raise InvalidTypeError.new "Invalid type: No matching ActiveRecord #{sanitized_type} model exists"
  end

  def self.build_cache
    @@cache = {
      patients: self.retrieve_cache_group(type: 'patient', keys: [:cpf]),
      physicians: self.retrieve_cache_group(type: 'physician', keys: [:crm_state, :crm_number]),
      test_reports: self.retrieve_cache_group(type: 'test_report', keys: [:token]),
    }
  end

  def self.reset_cache
    @@cache = nil
  end

  def self.create_record(type, *args)
    case type
    when 'patient'
      return
    when 'physician'
      return
    when 'test_report'
      return
    else
      raise InvalidTypeError.new "self.create_record doesn't know how to create a #{type} entry"
    end
  end

  def self.id_finder(type:, keys:)
    supported_types = ['patient', 'physician', 'test_report']
    raise InvalidTypeError.new "Supported types are #{supported_types.join(', ')}" unless supported_types.include? type

    self.build_cache unless @@cache.present?

    group = "#{type}s".to_sym
    composite_key = keys.join.to_sym
    
    if @@cache[group].has_key?(composite_key)
      @@cache[group][composite_key]
    else
      new_id = self.create_record(type)
      @@cache[group].store(composite_key, new_id)
      new_id
    end
  end
  
  def self.call(path)

    cached_patient_ids = self.retrieve_cache_group(type: 'patient', keys: [:cpf])
    cached_physician_ids = self.retrieve_cache_group(type: 'physician', keys: [:crm_state, :crm_number])
    cached_report_ids = self.retrieve_cache_group(type: 'test_report', keys: [:token])

    new_tests = []
    
    File.open(path) do |file|

      CSV.foreach(file, headers: true, col_sep: ';') do |row|

        patient_id = (
          if cached_patient_ids.has_key?(row[PATIENT_CPF].to_sym)
            cached_patient_ids[row[PATIENT_CPF].to_sym]
          else
            new_id = (Patient.create!(name: row[PATIENT_NAME],
                                      cpf: row[PATIENT_CPF],
                                      email: row[PATIENT_EMAIL],
                                      birth_date: row[PATIENT_BIRTH_DATE])
                     ).id 
            cached_patient_ids.store(row[PATIENT_CPF].to_sym, new_id)
            new_id
          end
        )

        crm_state = row[PHYSICIAN_CRM_STATE].strip.upcase
        crm_number = row[PHYSICIAN_CRM_NUMBER].strip.upcase
        full_crm = "#{crm_state}#{crm_number}".to_sym
        physician_id = (
          if cached_physician_ids.has_key?(full_crm)
            cached_physician_ids[full_crm]
          else
            new_id = (Physician.create!(name: row[PHYSICIAN_NAME],
                                        crm_state: crm_state,
                                        crm_number: crm_number)
                     ).id 
            cached_physician_ids.store(full_crm, new_id)
            new_id
          end
        )

        cached_report_ids
        report_id = (
          if cached_report_ids.has_key?(row[REPORT_TOKEN].to_sym)
            cached_report_ids[row[REPORT_TOKEN].to_sym]
          else
            patient_id
            new_id = (TestReport.create!(token: row[REPORT_TOKEN],
                                          patient_id: patient_id,
                                          physician_id: physician_id)  
                     ).id
            cached_report_ids.store(row[REPORT_TOKEN].to_sym, new_id)
            new_id
          end
        )
        
        new_tests << { patient_id: patient_id,
                       test_report_id: report_id,
                       name: row[TEST_NAME],
                       date: row[TEST_DATE],
                       result_range: row[TEST_RESULT_RANGE],
                       result: row[TEST_RESULT],
                     }
      end

      Test.insert_all(new_tests, record_timestamps: true)
    end
  end
end