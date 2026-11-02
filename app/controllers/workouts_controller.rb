class WorkoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workout, only: [:show, :edit, :update, :destroy]
  before_action :set_exercises, only: [:new, :create, :edit, :update]

  rescue_from ActiveRecord::NestedAttributes::TooManyRecords do
    render plain: "種目は30個、各種目のセットは100個まで登録できます。入力数を減らして再度お試しください。", status: :unprocessable_entity
  end

  def index
    @page = [params[:page].to_i, 1].max
    records = current_user.workouts.includes(workout_records: [:exercise, :workout_sets])
                          .order(date: :desc, created_at: :desc, id: :desc)
                          .limit(21).offset((@page - 1) * 20).to_a
    @has_next_page = records.size > 20
    @workouts = records.first(20)
  end

  def show; end
  def edit; end

  def new
    @workout = current_user.workouts.new(date: Date.current)
    source = if params[:copy_from].present?
      current_user.workouts.includes(workout_records: :workout_sets).find(params[:copy_from])
    elsif params[:copy_previous] == "true"
      current_user.workouts.includes(workout_records: :workout_sets)
                  .order(date: :desc, created_at: :desc, id: :desc).first
    end
    source&.workout_records&.each do |record|
      copy = @workout.workout_records.build(exercise_id: record.exercise_id, memo: record.memo)
      record.workout_sets.sort_by(&:set_number).each do |set|
        copy.workout_sets.build(set_number: set.set_number, weight_kg: set.weight_kg, reps: set.reps)
      end
    end
    if @workout.workout_records.empty?
      @workout.workout_records.build.workout_sets.build(set_number: 1)
    end
  end

  def create
    @workout = current_user.workouts.new(workout_params)
    if @workout.save
      redirect_to @workout, notice: "トレーニングを保存しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @workout.update(workout_params)
      redirect_to @workout, notice: "トレーニングを更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @workout.destroy!
    redirect_to workouts_path, notice: "トレーニングを削除しました。", status: :see_other
  end

  private

  def set_workout
    @workout = current_user.workouts.includes(workout_records: [:exercise, :workout_sets]).find(params[:id])
  end

  def set_exercises
    @exercises = Exercise.available_to(current_user).order(:name)
  end

  def workout_params
    params.require(:workout).permit(:date, :memo,
      workout_records_attributes: [:id, :exercise_id, :memo, :_destroy,
        workout_sets_attributes: [:id, :set_number, :weight_kg, :reps, :_destroy]])
  end
end
