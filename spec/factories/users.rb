FactoryBot.define do
  factory(:user) do
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    username { Faker::Internet.username }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    trait :admin do
      after(:create) { |user| user.update(is_admin: true) }
    end
  end
end
