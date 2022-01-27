class CreatePhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :photos, id: :uuid do |t|
      t.belongs_to :ticket, null: false, foreign_key: true, type: :uuid
      t.string :image

      t.timestamps
    end
  end
end
