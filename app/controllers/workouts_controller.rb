class WorkoutsController < ApplicationController
  before_action :authenticate_user!
  def index
    @workouts = current_user.workouts
                            .includes(workout_records: :workout_sets)
                            .includes(workout_records: :exercise)
                            .order(date: :desc, created_at: :desc)
  end

  def show
    @workout = current_user.workouts
                           .includes(workout_records: [:exercise, :workout_sets])
                           .find(params[:id])
  end

  def new
    @workout = current_user.workouts.new(date: Date.current)

    @exercises = Exercise.order(:name)

  source_workout =
    if params[:copy_from].present?
      current_user.workouts
                  .includes(workout_records: :workout_sets)
                  .find(params[:copy_from])
    elsif params[:copy_previous] == "true"
      current_user.workouts
                  .includes(workout_records: :workout_sets)
                  .order(date: :desc, created_at: :desc)
                  .first
    end

    if source_workout
    source_workout.workout_records.each do |source_record|
      new_record = @workout.workout_records.build(
        exercise_id: source_record.exercise_id
      )

      source_record.workout_sets.sort_by(&:set_number).each do |source_set|
        new_record.workout_sets.build(
          set_number: source_set.set_number,
          weight_kg: source_set.weight_kg,
          reps: source_set.reps
        )
      end
    end
  end

    if @workout.workout_records.empty?
      record = @workout.workout_records.build
      record.workout_sets.build(set_number: 1)
    end
  end

  def create
    @workout = current_user.workouts.new(workout_params)

    if @workout.save
      redirect_to workout_path(@workout),
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
