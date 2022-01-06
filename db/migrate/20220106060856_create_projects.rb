class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :description
      t.string :code, null: false
      t.boolean :is_active, null: false

      t.timestamps
    end

    add_index :projects, :code,                unique: true
  end
end
