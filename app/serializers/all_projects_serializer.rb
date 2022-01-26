class AllProjectsSerializer
    include JSONAPI::Serializer
    attributes :name, :description, :code, :is_active, :last_ticket_no, :created_at, :updated_at
    attributes :users do |object|
      object.users.count
    end
    attributes :tickets do |object|
      object.tickets.count
    end
  end
  