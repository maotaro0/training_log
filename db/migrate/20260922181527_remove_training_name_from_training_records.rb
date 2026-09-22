class RemoveTrainingNameFromTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    remove_column :training_records, :training_name, :string
  end
end
