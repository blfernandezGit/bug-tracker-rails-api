class AddLastTicketNoColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :last_ticket_no, :bigint
  end
end
