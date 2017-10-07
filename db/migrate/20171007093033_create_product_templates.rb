class CreateProductTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :product_templates do |t|
      t.integer :product_id, limit: 8
      t.string :product_title

      t.timestamps
    end
    add_index :product_templates, :product_id
  end
end
