class Project < ApplicationRecord
  # Projecect belongs to and has many users
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :tickets, dependent: :destroy

  validates :name, presence: true
  validates :code, uniqueness: true
end
