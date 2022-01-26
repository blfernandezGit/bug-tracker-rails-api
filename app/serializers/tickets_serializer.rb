class TicketsSerializer
    include JSONAPI::Serializer
    attributes :title, :status, :description, :ticket_no,
               :created_at, :updated_at
    attributes :project do |object|
      {
        id: object.project.id,
        code: object.project.code,
        name: object.project.name
      }
    end
    attributes :assignee do |object|
      if object.assignee
        {
          id: object.assignee.id,
          username: object.assignee.username
        }
      else
        {}
      end
    end
  end
  