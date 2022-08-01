FactoryBot.define do
  factory :test_report do
    token { SecureRandom.alphanumeric(7).upcase }
  end
end