class AddCartToMockups < ActiveRecord::Migration[5.1]
  def change
    add_column :mockups, :cart, :string
  end
end
