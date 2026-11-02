class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @profile = current_user.profile || current_user.build_profile
    @monthly_training_count = current_user.monthly_training_count
    @monthly_goal = @profile.monthly_goal
    @streak = current_user.training_streak
    @latest_workout = current_user.workouts.includes(workout_records: [:exercise, :workout_sets])
                                  .order(date: :desc, created_at: :desc, id: :desc).first
    @chart_exercises = Exercise.joins(workout_records: :workout)
                              .where(workouts: { user_id: current_user.id }).distinct.order(:name)
    @selected_exercise = @chart_exercises.find_by(id: params[:exercise_id]) || @chart_exercises.first
    if @selected_exercise
      @progress = ExerciseProgress.new(user: current_user, exercise: @selected_exercise)
      values = @progress.values(:weight).compact
      @weight_difference = values.last - values[-2] if values.length >= 2
      @best_updated = values.any? && (values.length == 1 || values.last > values[0...-1].max)
    end
  end
end
