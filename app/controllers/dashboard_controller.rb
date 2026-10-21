class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @monthly_training_count = current_user.workouts
      .where(date: Date.current.all_month)
      .distinct
      .count(:date)

    @latest_workout = current_user.workouts
      .includes(workout_records: [:exercise, :workout_sets])
      .order(date: :desc, created_at: :desc)
      .first

    @latest_record = @latest_workout&.workout_records&.first

    @latest_set = @latest_record&.workout_sets
      &.sort_by(&:set_number)
      &.first

    @chart_exercises = Exercise
      .joins(workout_records: :workout)
      .where(workouts: { user_id: current_user.id })
      .distinct
      .order(:name)

    @selected_exercise =
      @chart_exercises.find_by(id: params[:exercise_id]) ||
      @chart_exercises.first

    @chart_labels = []
    @chart_weights = []

    @growth_record = nil
    @weight_difference = nil
    @personal_best_weight = nil

    if @selected_exercise
      records = WorkoutRecord
        .joins(:workout)
        .includes(:workout_sets, :exercise, :workout)
        .where(
          exercise_id: @selected_exercise.id,
          workouts: { user_id: current_user.id }
        )
        .order("workouts.date ASC, workouts.created_at ASC")

      daily_max_weights = {}

      records.each do |record|
        weights = record.workout_sets.filter_map(&:weight_kg)

        next if weights.empty?

        date = record.workout.date
        max_weight = weights.max.to_f

        daily_max_weights[date] = [
          daily_max_weights[date] || 0,
          max_weight
        ].max
      end

      @chart_labels = daily_max_weights.keys.map do |date|
        date.strftime("%m/%d")
      end

      @chart_weights = daily_max_weights.values

      if @chart_weights.any?
        @personal_best_weight = @chart_weights.max

        if @chart_weights.size >= 2
          @weight_difference =
            @chart_weights.last - @chart_weights[-2]

          @growth_record = @selected_exercise
        end
      end
    end
  end
end