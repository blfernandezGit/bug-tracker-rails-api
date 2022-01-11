class ProjectMembershipSerializer
  include JSONAPI::Serializer
  attributes :user_id, :project_id

  belongs_to :user
  belongs_to :project
end
