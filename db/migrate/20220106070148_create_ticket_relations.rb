class CreateTicketRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :ticket_relations do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :related_ticket_id, null: false

      t.timestamps
    end

    add_foreign_key :ticket_relations, :tickets, column: :related_ticket_id
  end
end
