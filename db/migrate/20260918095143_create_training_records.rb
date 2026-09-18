class CreateTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :training_records do |t|
      t.date :training_day
      t.string :training_name
      t.decimal :weight_kg
      t.integer :reps
      t.integer :set_count
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
