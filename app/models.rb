class Patient < ActiveRecord::Base
  has_many :tests
end

class Physician < ActiveRecord::Base
end

class Test < ActiveRecord::Base
  belongs_to :patient
end