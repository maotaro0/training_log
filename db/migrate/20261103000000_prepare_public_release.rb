class PreparePublicRelease < ActiveRecord::Migration[7.1]
  def change
    add_reference :exercises, :user, foreign_key: true
    remove_index :exercises, :name
    add_index :exercises, [:user_id, :name], unique: true
    add_index :exercises, :name, unique: true, where: "user_id IS NULL", name: "index_shared_exercise_names"
    add_index :workouts, [:user_id, :date, :created_at]
  end
end
