class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :author, class_name: 'User'

  # Ticket has many comments
  has_many :comments
  # Ticket has many related tickets and is related to many tickets
  has_many :ticket_relations
  has_many :related_tickets, through: :ticket_relations
  has_many :inverse_ticket_relations, class_name: 'TicketRelation', foreign_key: :related_ticket_id
  has_many :inverse_related_tickets, through: :inverse_ticket_relations, source: :ticket

  validates :title, presence: true
  STATUS = %w[Open ForFixing ForTesting Closed Cancelled].freeze
  validates :status, inclusion: { in: STATUS }
end
