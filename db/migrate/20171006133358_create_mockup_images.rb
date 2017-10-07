class CreateMockupImages < ActiveRecord::Migration[5.1]
  def change
    create_table :mockup_images do |t|
      t.integer :mockup_id, limit: 8
      t.string :variant_ids
      t.string :image
      t.string :title

      t.timestamps
    end
    add_index :mockup_images, :mockup_id
  end
end
