class CreatePhysiciansTable < ActiveRecord::Migration[7.0]
  def change
    create_table :physicians do |t|
      t.string :name
      t.string :crm_number
      t.string :crm_state

      t.timestamps
    end

    add_index :physicians, [:crm_state, :crm_number], unique: true, name: 'by_crm_state_number'
  end
end
