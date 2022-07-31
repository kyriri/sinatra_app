FactoryBot.define do
  factory :physician do
    crm_state { ['pb', 'aL', 'RN', 'Se'].sample }
    crm_number { 51 + rand(1..9999) }
  end
end