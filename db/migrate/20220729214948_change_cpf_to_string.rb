class ChangeCpfToString < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up   { change_column :patients, :cpf, :string }
      dir.down { change_column :patients, :cpf, :integer }
    end
  end
end
