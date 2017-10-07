class CreateTemplateData < ActiveRecord::Migration[5.1]
  def change
    create_table :template_data do |t|
      t.integer :product_id, limit: 8
      t.string :title
      t.string :group
      t.integer :width
      t.integer :height
      t.string :placement
      t.string :hashdata
      t.integer :area_width
      t.integer :area_height
      t.integer :area_x
      t.integer :area_y
      t.integer :safe_area_width
      t.integer :safe_area_height
      t.integer :safe_area_x
      t.integer :safe_area_y
      t.integer :order
      t.string :file_background
      t.string :file_overlay

      t.timestamps
    end
    add_index :template_data, :product_id
  end
end
