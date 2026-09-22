class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|
      t.string :name, null: false

      t.timestamps
    end
    
    add_index :exercises, :name, unique: true
  end
end
