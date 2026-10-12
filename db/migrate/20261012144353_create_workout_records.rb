class CreateWorkoutRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :workout_records do |t|
      t.references :workout, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.text :memo

      t.timestamps
    end
  end
end
