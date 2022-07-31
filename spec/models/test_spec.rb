RSpec.describe Test do
  let(:app) { App.new }

  context '#patient_id' do
    it 'is an integer' do
      patient = create(:patient)
      report = create(:test_report)
      new_test = build(:test, patient_id: patient.id, test_report_id: report.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer')
  
      expect { new_test.save }.to change { Test.all.size }.by 1
    end

    it 'cannot be a word' do
      patient = create(:patient)
      report = create(:test_report)
      lost_test = build(:test, patient_id: 'funny lady', test_report_id: report.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer')
  
      expect { lost_test.save }.to raise_error ActiveRecord::InvalidForeignKey
    end 

    it 'cannot be nil' do
      report = create(:test_report)
      lost_test = build(:test, patient_id: nil, test_report_id: report.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer')
  
      expect { lost_test.save }.to raise_error ActiveRecord::NotNullViolation
    end

    it 'cannot be blank' do
      report = create(:test_report)
      lost_test = { patient_id: '', test_report_id: report.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer' }
  
        expect {
          Test.insert_all([lost_test], record_timestamps: true)
        }.to raise_error ActiveRecord::NotNullViolation
    end
  end
  
  context '#test_report_id' do
    it 'cannot be a word' do
      patient = create(:patient)
      report = create(:test_report)
      lost_test = build(:test, test_report_id: 'that of yesterday', patient_id: patient.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer')
  
      expect { lost_test.save }.to raise_error ActiveRecord::InvalidForeignKey
    end 

    it 'cannot be nil' do
      patient = create(:patient)
      lost_test = build(:test, test_report_id: nil, patient_id: patient.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer')
  
      expect { lost_test.save }.to raise_error ActiveRecord::NotNullViolation
    end

    it 'cannot be blank' do
      patient = create(:patient)
      lost_test = { test_report_id: '', patient_id: patient.id,
        name: 'realitiy check', date: 5.days.ago,
        result_range: 'crazy-normal-daydreamer', result: 'daydreamer' }
  
        expect {
          Test.insert_all([lost_test], record_timestamps: true)
        }.to raise_error ActiveRecord::NotNullViolation
    end
  end
end