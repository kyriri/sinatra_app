class Patient < ActiveRecord::Base
end

class Physician < ActiveRecord::Base
end

class Test < ActiveRecord::Base
  belongs_to :patient
  belongs_to :test_report
end

class TestReport < ActiveRecord::Base
  belongs_to :patient
  belongs_to :physician
  has_many :tests
end