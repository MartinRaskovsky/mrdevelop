class AddColumnsToMockup < ActiveRecord::Migration[5.1]
  def change
    add_column :mockups, :thumb_url, :string
    add_column :mockups, :product_url, :string
    add_column :mockups, :image_url, :string
  end
end
