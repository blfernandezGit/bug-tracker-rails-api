class CreateTicketRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :ticket_relations, id: :uuid do |t|
      t.references :ticket, null: false, foreign_key: true, type: :uuid
      t.references :related_ticket, null: false, foreign_key: { to_table: :tickets }, type: :uuid

      t.timestamps
    end
  end
end
