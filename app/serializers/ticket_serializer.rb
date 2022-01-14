class TicketSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :resolution, :status, :project_id, :author_id, :assignee_id

  belongs_to :project
  belongs_to :author, class_name: 'User'
  belongs_to :assignee, class_name: 'User'
  has_many :comments
  has_many :ticket_relations
  has_many :related_tickets, through: :ticket_relations, source: :ticket
  has_many :inverse_ticket_relations, class_name: 'TicketRelation', foreign_key: 'related_ticket_id'
  has_many :inverse_related_tickets, through: :inverse_ticket_relations, source: :ticket
end
