class CreateMockupGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :mockup_groups do |t|
      t.integer :mockup_id, limit: 8
      t.string :variant_ids
      t.string :placement
      t.string :mockup_url

      t.timestamps
    end
    add_index :mockup_groups, :mockup_id
  end
end
