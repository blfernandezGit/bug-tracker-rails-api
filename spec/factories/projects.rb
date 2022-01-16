FactoryBot.define do
  factory :project do
    name { Faker::Name.name }
    description { Faker::Name.name }
    is_active { true }
  end
end
