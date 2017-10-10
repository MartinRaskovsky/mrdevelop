class AddOrderStatusUrlToMockups < ActiveRecord::Migration[5.1]
  def change
    add_column :mockups, :order_status_url, :string
  end
end
