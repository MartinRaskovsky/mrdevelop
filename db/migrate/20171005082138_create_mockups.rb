class CreateMockups < ActiveRecord::Migration[5.1]
  def change
    create_table :mockups do |t|
      t.string :mockup_url
      t.string :placement
      t.string :variant_ids
      t.string :thumb_url
      t.string :product_url
      t.string :image_url
      t.integer :printful_id, limit: 8
      t.integer :shopify_id, limit: 8

      t.timestamps
    end
  end
end
