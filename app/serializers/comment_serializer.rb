class CommentSerializer
  include JSONAPI::Serializer
  attributes :ticket, :comment_text, :created_at, :updated_at, :user
end
