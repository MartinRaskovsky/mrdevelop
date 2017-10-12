class CreatePrintfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :printfiles do |t|
      t.string :printfile_url
      t.integer :printful_id, limit: 8
      t.integer :shopify_id, limit: 8
      t.integer :job_id

      t.timestamps
    end
    add_index :printfiles, :printful_id
    add_index :printfiles, :shopify_id
  end
end
