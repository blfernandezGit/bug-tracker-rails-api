FactoryBot.define do
  factory :ticket do
    title { 'MyTitle' }
    description { 'MyDescription' }
    resolution { 'MyResolution' }
    status { 'Open' }
    project
    user
  end
end
