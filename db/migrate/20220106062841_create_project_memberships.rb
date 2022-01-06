class CreateProjectMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :project_memberships, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.belongs_to :project, null: false, foreign_key: true, type: :uuid
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
