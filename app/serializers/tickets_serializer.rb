class TicketsSerializer
    include JSONAPI::Serializer
    attributes :title, :status, :ticket_no,
               :created_at, :updated_at
    attributes :project do |object|
      {
        code: object.project.code,
        name: object.project.name
      }
    end
    attributes :assignee do |object|
      if object.assignee
        {
          username: object.assignee.username
        }
      else
        {}
      end
    end
  end
  