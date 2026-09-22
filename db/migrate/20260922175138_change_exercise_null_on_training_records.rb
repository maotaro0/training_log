class ChangeExerciseNullOnTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    change_column_null :training_records, :exercise_id, false
  end
end
