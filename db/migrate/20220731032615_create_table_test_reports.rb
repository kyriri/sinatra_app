class CreateTableTestReports < ActiveRecord::Migration[7.0]
  def change
    create_table :test_reports do |t|
      t.belongs_to :patient, foreign_key: true
      t.belongs_to :physician, foreign_key: true
      t.string :token, index: { unique: true }
      
      t.timestamps
    end

    add_belongs_to :tests, :test_report, foreign_key: true
  end
end
