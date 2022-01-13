class UserSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :email, :username

  has_many :project_memberships
  has_many :projects, through: :project_memberships
  has_many :author_tickets, class_name: 'Ticket', foreign_key: 'author_id'
  has_many :assignee_tickets, class_name: 'Ticket', foreign_key: 'assignee_id'
  has_many :comments
end
