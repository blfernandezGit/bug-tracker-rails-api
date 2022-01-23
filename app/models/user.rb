class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  #  :confirmable

  # User belongs to and has many projects
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  # User has many authored tickets and has many assigned tickets
  has_many :author_tickets, class_name: 'Ticket', foreign_key: 'author_id', dependent: :destroy
  has_many :assignee_tickets, class_name: 'Ticket', foreign_key: 'assignee_id'
  # User has many comments
  has_many :comments, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username,
            presence: true,
            uniqueness: true,
            format: {
              with: /\A[a-z0-9]+\Z/,
              message: 'must be alphanumeric with lowercase letters'
            }

  scope :admins, -> { where(is_admin: true) }
  scope :clients, -> { where(is_admin: false) }

  def generate_jwt
    JWT.encode({ id: id, exp: 1.day.from_now.to_i }, Rails.application.secrets.secret_key_base)
  end
end
