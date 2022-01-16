class ChangeCodePresence < ActiveRecord::Migration[6.1]
  def change
    change_column_null :projects, :code, true
  end
end
