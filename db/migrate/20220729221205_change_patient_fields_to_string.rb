class ChangePatientFieldsToString < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :patients, :name, :string
        change_column :patients, :email, :string
      end
      dir.down do
        change_column :patients, :name, :text
        change_column :patients, :email, :text
      end
    end
  end
end
