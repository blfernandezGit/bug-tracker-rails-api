class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.belongs_to :ticket, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.text :comment_text, null: false

      t.timestamps
    end
  end
end
