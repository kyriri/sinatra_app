class Patient < ActiveRecord::Base
  validates_uniqueness_of :cpf
end

class Physician < ActiveRecord::Base
end

class Test < ActiveRecord::Base
  belongs_to :patient
end

class TestReport < ActiveRecord::Base
  belongs_to :patient
  belongs_to :physician
  has_many :tests
end