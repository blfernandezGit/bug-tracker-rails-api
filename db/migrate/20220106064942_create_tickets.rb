class CreateTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description
      t.text :resolution
      t.string :status, null: false, default: 'open'
      t.belongs_to :project, null: false, foreign_key: true
      t.references :author_id, null: false
      t.references :assignee_id

      t.timestamps
    end

    add_foreign_key :tickets, :users, column: :author_id
    add_foreign_key :tickets, :users, column: :assignee_id
  end
end
