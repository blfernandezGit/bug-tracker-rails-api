FactoryBot.define do
  factory :project do
    name { 'MyString' }
    description { 'MyString' }
    code { 'MyCode ' }
    is_active { false }
  end
end
