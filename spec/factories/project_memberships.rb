FactoryBot.define do
  factory :project_membership do
    user { nil }
    project { nil }
    is_active { false }
  end
end
