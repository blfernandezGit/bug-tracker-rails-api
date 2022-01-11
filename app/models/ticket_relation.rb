class TicketRelation < ApplicationRecord
  belongs_to :ticket
  belongs_to :related_ticket, class_name: "Ticket"
end
