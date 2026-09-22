class AddExerciseToTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    add_reference :training_records, :exercise, foreign_key: true
  end
end
