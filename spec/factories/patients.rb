FactoryBot.define do
  factory :patient do
    cpf { "#{rand(999)}.#{rand(999)}.#{rand(999)}-#{rand(99)}" }
  end
end