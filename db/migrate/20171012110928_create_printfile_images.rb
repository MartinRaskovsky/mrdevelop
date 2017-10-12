class CreatePrintfileImages < ActiveRecord::Migration[5.1]
  def change
    create_table :printfile_images do |t|
      t.integer :printfile_id, limit: 8
      t.string :variant_ids
      t.string :image
      t.string :title

      t.timestamps
    end
    add_index :printfile_images, :printfile_id
  end
end
