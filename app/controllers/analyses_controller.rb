class AnalysesController < ApplicationController
  before_action :authenticate_user!

  def show
    @exercises = Exercise.joins(workout_records: :workout)
      .where(workouts: { user_id: current_user.id }).distinct.order(:name)
    @exercise = @exercises.find_by(id: params[:exercise_id]) || @exercises.first
    @period = %w[30 90 all].include?(params[:period]) ? params[:period] : "30"
    @metric = %w[weight volume reps].include?(params[:metric]) ? params[:metric] : "weight"
    @metric_label, @unit = { "weight" => ["最大重量", "kg"], "volume" => ["総負荷量", "kg"], "reps" => ["合計回数", "回"] }.fetch(@metric)
    since = @period == "all" ? nil : Date.current - (@period.to_i - 1)
    @progress = ExerciseProgress.new(user: current_user, exercise: @exercise, since: since) if @exercise
  end
end
