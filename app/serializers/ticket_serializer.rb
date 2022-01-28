class TicketSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers
  attributes :title, :description, :resolution, :status, :ticket_no,
             :created_at, :updated_at
  attributes :project do |object|
    {
      id: object.project.id,
      code: object.project.code,
      name: object.project.name
    }
  end
  attributes :author do |object|
    {
      id: object.author.id,
      username: object.author.username,
      first_name: object.author.first_name,
      last_name: object.author.last_name
    }
  end
  attributes :assignee do |object|
    if object.assignee
      {
        id: object.assignee.id,
        username: object.assignee.username
      }
    else
      {}
    end
  end
  attributes :related_tickets do |object|
    object.related_tickets.collect do |related_ticket|
      {
        id: related_ticket.id,
        ticket_no: related_ticket.ticket_no,
        title: related_ticket.title,
        status: related_ticket.status
      }
    end
  end
  attributes :inverse_related_tickets do |object|
    object.inverse_related_tickets.collect do |related_ticket|
      {
        id: related_ticket.id,
        ticket_no: related_ticket.ticket_no,
        title: related_ticket.title,
        status: related_ticket.status
      }
    end
  end
  attributes :comments do |object|
    object.comments.includes(:user).collect do |comment|
      {
        id: comment.id,
        comment_text: comment.comment_text,
        author: {
          username: comment.user.username,
          first_name: comment.user.first_name,
          last_name: comment.user.last_name
        },
        created_at: comment.created_at,
        updated_at: comment.updated_at
      }
    end
  end
  attributes :image do |object|
    if object.image.attached?
      {
        url: Rails.application.routes.url_helpers.rails_blob_url(object.image)
      }
    end
  end
end
