class AddIndexToCpf < ActiveRecord::Migration[7.0]
  def change
    add_index :patients, :cpf, unique: true
  end
end
