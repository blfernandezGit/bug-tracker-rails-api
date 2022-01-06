FactoryBot.define do
  factory :ticket do
    description { "MyText" }
    resolution { "MyText" }
    status { "MyString" }
    project { nil }
    user { nil }
  end
end
