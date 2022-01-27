class CreatePhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :photos, id: :uuid do |t|
      t.string :image

      t.timestamps
    end
  end
end
