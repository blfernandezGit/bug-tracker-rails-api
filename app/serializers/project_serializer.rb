class ProjectSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :code, :is_active, :last_ticket_no, :created_at, :updated_at
  attributes :users do |object|
    object.users.collect do |user|
      {
        username: user.username,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        is_admin: user.is_admin,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end
  end
  attributes :tickets do |object|
    object.tickets.collect do |ticket|
      {
        ticket_no: ticket.ticket_no,
        title: ticket.title,
        status: ticket.status,
        created_at: ticket.created_at,
        updated_at: ticket.updated_at
      }
    end
  end
end
