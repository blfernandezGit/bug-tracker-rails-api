class Ticket < ApplicationRecord
  belongs_to :project
  belongs_to :author, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true

  # Ticket has many comments
  has_many :comments, dependent: :destroy
  # Ticket has many related tickets and is related to many tickets
  has_many :ticket_relations, dependent: :destroy
  has_many :related_tickets, through: :ticket_relations
  has_many :inverse_ticket_relations, class_name: 'TicketRelation', foreign_key: :related_ticket_id, dependent: :destroy
  has_many :inverse_related_tickets, through: :inverse_ticket_relations, source: :ticket
  has_one_attached :image

  validates :title, presence: true
  STATUS = %w[Open ForFixing ForTesting Closed Cancelled].freeze
  validates :status, inclusion: { in: STATUS }
end
