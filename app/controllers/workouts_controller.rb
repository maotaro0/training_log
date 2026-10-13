class WorkoutsController < ApplicationController
  before_action :authenticate_user!

  def new
    @workout = current_user.workouts.new(date: Date.current)

    2.times do
      record = @workout.workout_records.build

      2.times do |index|
        record.workout_sets.build(set_number: index + 1)
      end
    end

    @exercises = Exercise.order(:name)
  end

  def create
    @workout = current_user.workouts.new(workout_params)

    if @workout.save
      redirect_to root_path,
                  notice: "トレーニングを保存しました。"
    else
      @exercises = Exercise.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def workout_params
    params.require(:workout).permit(
      :date,
      :memo,
      workout_records_attributes: [
        :exercise_id,
        :memo,
        :_destroy,
        workout_sets_attributes: [
          :set_number,
          :weight_kg,
          :reps,
          :_destroy
        ]
      ]
    )
  end
end
