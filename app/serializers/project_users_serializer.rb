class ProjectUsersSerializer
    include JSONAPI::Serializer
    attributes :name, :code
    attributes :users do |object|
      object.users.collect do |user|
        {
          username: user.username,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          is_admin: user.is_admin,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
  