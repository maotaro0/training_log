class CreateWorkoutSets < ActiveRecord::Migration[7.1]
  def change
    create_table :workout_sets do |t|
      t.references :workout_record, null: false, foreign_key: true
      t.integer :set_number
      t.decimal :weight_kg, precision: 6, scale: 2
      t.integer :reps
      t.boolean :is_pr, default: false, null: false

      t.timestamps
    end
  end
end
