FactoryBot.define do
  factory :ticket, aliases: [:author_ticket] do
    title { Faker::Name.name }
    description { Faker::Name.name }
    status { 'Open' }
    ticket_no { 1 }
    project
    author
  end
end
