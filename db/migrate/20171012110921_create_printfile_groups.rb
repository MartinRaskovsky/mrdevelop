class CreatePrintfileGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :printfile_groups do |t|
      t.integer :printfile_id, limit: 8
      t.string :variant_ids
      t.string :placement
      t.string :printfile_url

      t.timestamps
    end
    add_index :printfile_groups, :printfile_id
  end
end
