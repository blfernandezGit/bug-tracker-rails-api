class TicketRelationSerializer
  include JSONAPI::Serializer
  attributes :ticket_id, :related_ticket_id

  belongs_to :ticket
  belongs_to :related_ticket, class_name: 'Ticket', serializer: TicketSerializer
end
