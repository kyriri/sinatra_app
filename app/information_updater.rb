# frozen_string_literal: true

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

  def self.create_record(type, attrs)
    attrs.transform_values! { |v| v.is_a?(String) ? v.strip : v }

    case type
    when 'patient'
      return Patient.create!(attrs).id
    when 'physician'
      attrs[:crm_state] = attrs[:crm_state].upcase 
      attrs[:crm_number] = attrs[:crm_number].upcase 
      return Physician.create!(attrs).id
    when 'test_report'
      return TestReport.create!(attrs).id
    when 'test'
      return Test.create!(attrs).id
    else
      raise InvalidTypeError.new "InformationUpdater.create_record doesn't know how to create a #{type} entry"
    end
  end

  def self.get_id(type:, keys:, attrs:)
    supported_types = ['patient', 'physician', 'test_report']
    raise InvalidTypeError.new "Supported types are #{supported_types.join(', ')}" unless supported_types.include? type

    self.build_cache unless @@cache.present?

    group = "#{type}s".to_sym
    composite_key = keys.join.to_sym
    
    if @@cache[group].has_key?(composite_key)
      @@cache[group][composite_key]
    else
      new_id = self.create_record(type, attrs)
      @@cache[group].store(composite_key, new_id)
      new_id
    end
  end
  
  def self.call(path)
    new_tests = []

    self.build_cache
    
    File.open(path) do |file|

      CSV.foreach(file, headers: true, col_sep: ';') do |row|
        data = {
          :patient => {
            name: row[PATIENT_NAME],
            cpf: row[PATIENT_CPF],
            email: row[PATIENT_EMAIL],
            birth_date: row[PATIENT_BIRTH_DATE],
          },
          :physician => {
            name: row[PHYSICIAN_NAME],
            crm_state: row[PHYSICIAN_CRM_STATE].strip.upcase,
            crm_number: row[PHYSICIAN_CRM_NUMBER].strip.upcase,
          },
          :test_report => {
            token: row[REPORT_TOKEN],
            patient_id: nil,
            physician_id: nil,
          },
          :test => {
            name: row[TEST_NAME],
            date: row[TEST_DATE],
            result_range: row[TEST_RESULT_RANGE],
            result: row[TEST_RESULT],
            patient_id: nil,
            test_report_id: nil,
          },
        }

        patient_id = self.get_id(type: 'patient', attrs: data[:patient],
          keys: [data[:patient][:cpf]])
        data[:test_report][:patient_id] = patient_id
        data[:test][:patient_id] = patient_id

        physician_id = self.get_id(type: 'physician', attrs: data[:physician],
          keys: [data[:physician][:crm_state], data[:physician][:crm_number]])
        data[:test_report][:physician_id] = physician_id

        test_report_id = self.get_id(type: 'test_report', attrs: data[:test_report],
          keys: [data[:test_report][:token]])
        data[:test][:test_report_id] = test_report_id
        
        new_tests << data[:test]
      end

      Test.insert_all(new_tests, record_timestamps: true)
    end
  end
end