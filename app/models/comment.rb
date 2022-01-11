class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  validates :comment_text, presence: true
end
