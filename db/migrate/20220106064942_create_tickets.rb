class CreateTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :tickets, id: :uuid do |t|
      t.string :title, null: false
      t.text :description
      t.text :resolution
      t.string :status, null: false, default: 'open'
      t.belongs_to :project, null: false, foreign_key: true, type: :uuid
      t.references :author, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :assignee, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end
  end
end
