class TicketRelation < ApplicationRecord
  belongs_to :ticket
  belongs_to :related, class_name: "Ticket"
end
