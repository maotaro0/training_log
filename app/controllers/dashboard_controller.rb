class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @monthly_training_count = current_user.monthly_training_count

    @latest_record = current_user.training_records
                                 .includes(:exercise)
                                 .order(training_day: :desc, created_at: :desc)
                                 .first

    @growth_record = current_user.training_records
                                 .includes(:exercise)
                                 .where.not(weight_kg: nil)
                                 .order(training_day: :desc, created_at: :desc)
                                 .detect do |record|
      record.previous_record.present?
    end

    @personal_best_record =
      if @growth_record
        current_user.training_records
                    .where(exercise_id: @growth_record.exercise_id)
                    .where.not(weight_kg: nil)
                    .order(weight_kg: :desc, reps: :desc)
                    .first
      end

    @chart_exercises = Exercise.joins(:training_records)
                               .where(training_records: { user_id: current_user.id })
                               .where.not(training_records: { weight_kg: nil })
                               .distinct
                               .order(:name)

    @selected_exercise =
      @chart_exercises.find_by(id: params[:exercise_id]) ||
      @chart_exercises.first

    @chart_records =
      if @selected_exercise
        current_user.training_records
                    .where(exercise_id: @selected_exercise.id)
                    .where.not(weight_kg: nil)
                    .order(:training_day, :created_at)
      else
        current_user.training_records.none
      end

    @chart_labels = @chart_records.map do |record|
      record.training_day.strftime("%m/%d")
    end

    @chart_weights = @chart_records.map do |record|
      record.weight_kg.to_f
    end
  end
end