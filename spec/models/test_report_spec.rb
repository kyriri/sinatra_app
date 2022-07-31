RSpec.describe TestReport do
  let(:app) { App.new }

  context '#token' do
    it 'should be checked for uniqueness by ActiveRecord' do
      create(:test_report, token: 'MVF84NV')
      duplicate = build(:test_report, token: 'MVF84NV')
      
      duplicate.valid?

      expect(duplicate.errors.of_kind?(:token, :taken)).to be_truthy
    end

    it 'should be checked for uniqueness by the db' do
      create(:test_report, token: 'MVF84NV')

      # indirect test: insert_all skips ActiveRecord validations, but the record 
      # won't be saved if it violates any DB constraints
      result = TestReport.insert_all([{ token: 'MVF84NV' }], record_timestamps: true)

      expect(result).to be_empty
    end
  end
end