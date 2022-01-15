class AddColumnToTickets < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :ticket_no, :bigint, null: false
  end
end
