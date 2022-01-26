class UserSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :email, :username, :created_at, :updated_at, :is_admin
  attributes :projects do |object|
    object.projects.collect do |project|
      {
        id: project.id,
        code: project.code,
        name: project.name,
        description: project.description,
        last_ticket_no: project.last_ticket_no,
        created_at: project.created_at,
        updated_at: project.updated_at
      }
    end
  end
  attributes :author_tickets do |object|
    object.author_tickets.collect do |author_ticket|
      {
        id: author_ticket.id,
        ticket_no: author_ticket.ticket_no,
        title: author_ticket.title,
        status: author_ticket.status,
        created_at: author_ticket.created_at
      }
    end
  end
  attributes :assignee_tickets do |object|
    object.assignee_tickets.collect do |assignee_ticket|
      {
        id: assignee_ticket.id,
        ticket_no: assignee_ticket.ticket_no,
        title: assignee_ticket.title,
        status: assignee_ticket.status,
        created_at: assignee_ticket.created_at
      }
    end
  end
end
