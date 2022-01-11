FactoryBot.define do
  factory :comment do
    ticket
    user
    comment_text { "MyComment" }
  end
end
