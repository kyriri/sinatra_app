class CreateTableTests < ActiveRecord::Migration[7.0]
  def change
    create_table :tests do |t|
      t.string :name
      t.datetime :date
      t.string :result_range
      t.string :result

      t.timestamps
    end

    add_reference :tests, :patient, foreign_key: true
  end
end
