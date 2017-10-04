class CreateMockups < ActiveRecord::Migration[5.1]
  def change
    create_table :mockups do |t|
      t.string :mockup_url
      t.string :placement
      t.string :variant_ids

      t.timestamps
    end
  end
end
