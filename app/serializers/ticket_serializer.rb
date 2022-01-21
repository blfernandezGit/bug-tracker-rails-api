class TicketSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :resolution, :status, :project_id, :author_id, :assignee_id, :ticket_no,
             :created_at, :updated_at

  belongs_to :project
  belongs_to :author, class_name: 'User', serializer: UserSerializer
  belongs_to :assignee, class_name: 'User', serializer: UserSerializer
  has_many :comments
  has_many :ticket_relations
  has_many :related_tickets, through: :ticket_relations, serializer: TicketRelationSerializer
  has_many :inverse_ticket_relations, class_name: 'TicketRelation', foreign_key: :related_ticket_id,
                                      serializer: TicketRelationSerializer
  has_many :inverse_related_tickets, through: :inverse_ticket_relations, source: :ticket,
                                     serializer: TicketRelationSerializer
end
