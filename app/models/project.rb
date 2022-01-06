class Project < ApplicationRecord
    # Projecect belongs to and has many users
    has_many :project_memberships
    has_many :users, through: :project_memberships
end
