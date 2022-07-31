class MakeRelationsMandatoryForTests < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tests, :patient_id, false
    change_column_null :tests, :test_report_id, false
  end
end
