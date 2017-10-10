class DropProgressFromDelayedJobs < ActiveRecord::Migration[5.1]
  def change
    remove_column :delayed_jobs, :progress_stage
    remove_column :delayed_jobs, :progress_current
    remove_column :delayed_jobs, :progress_max
  end
end
