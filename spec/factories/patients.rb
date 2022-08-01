FactoryBot.define do
  factory :patient do
    cpf { (1..11).map { rand(9).to_s }.join.insert(6, '.').insert(3, '.').insert(-3, '-') }
  end
end