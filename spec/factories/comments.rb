FactoryBot.define do
  factory :comment do
    ticket { nil }
    user { nil }
    comment_text { "MyText" }
  end
end
