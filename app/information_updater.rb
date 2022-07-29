require 'csv'

class InformationUpdater
  
  def self.read(path)
    CSV.read(path, col_sep: ';')
  end

end