class ProjectSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :code, :is_active

  has_many :project_memberships
  has_many :users, through: :project_memberships
  # has_many :tickets
end
