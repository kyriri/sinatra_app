class Patients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients do |t|
      t.text    :name
      t.integer :cpf
      t.text    :email
      t.date    :birth_date

      t.timestamps
    end
  end
end
