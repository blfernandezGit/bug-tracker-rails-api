FactoryBot.define do
  factory :user, aliases: [:author] do
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    username { Faker::Internet.username.gsub('_','').gsub('.','') }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    trait :admin do
      after(:create) { |user| user.update(is_admin: true) }
    end
  end
end
