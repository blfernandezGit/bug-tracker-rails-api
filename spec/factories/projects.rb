FactoryBot.define do
  factory :project do
    name { Faker::Name.name }
    description { Faker::Name.name }
    code { Faker::Internet.username }
    is_active { true }
  end
end
