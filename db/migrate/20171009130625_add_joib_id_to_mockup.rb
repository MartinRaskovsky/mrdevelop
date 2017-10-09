class AddJoibIdToMockup < ActiveRecord::Migration[5.1]
  def change
    add_column :mockups, :job_id, :integer
  end
end
