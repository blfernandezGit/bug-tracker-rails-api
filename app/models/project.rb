class Project < ApplicationRecord
    # Projecect belongs to and has many users
    has_many :project_memberships
    has_many :users, through: :project_memberships

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true

    before_create :slugify

    def slugify
        self.code = name.parameterize #creates url safe version of the name
    end 
end