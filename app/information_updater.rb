require 'csv'

class InformationUpdater
  
  def self.read(path)
    CSV.read(path, col_sep: ';')
  end

  def self.create_patients(data)
    indexes = {
      patient_cpf: data[0].index('cpf'),
      patient_name: data[0].index('nome paciente'),
      patient_email: data[0].index('email paciente'),
      patient_birth_date: data[0].index('data nascimento paciente'),
      patient_address_street: data[0].index('endereço/rua paciente'),
      patient_address_city: data[0].index('cidade paciente'),
      patient_address_state: data[0].index('estado patiente'),
    }

    data.shift # removes headers

    data.each do |line|

      if Patient.where(cpf: line[indexes[:patient_cpf]]).empty?
        Patient.create(
          name: line[indexes[:patient_name]],
          cpf: line[indexes[:patient_cpf]],
          email: line[indexes[:patient_email]],
          birth_date: line[indexes[:patient_birth_date]],
        )
      end
    end
  end
end