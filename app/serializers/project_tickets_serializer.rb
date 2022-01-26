class ProjectTicketsSerializer
    include JSONAPI::Serializer
    attributes :name, :code
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
  