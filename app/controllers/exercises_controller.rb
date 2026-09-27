class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise, only: [:edit, :update, :destroy]

  def index
    @exercises = Exercise.order(:name)
  end

  def new
    @exercise = Exercise.new
  end

def create
  @exercise = Exercise.new(exercise_params)

  if @exercise.save
    if params[:return_to] == new_training_record_path
      redirect_to new_training_record_path,
                  notice: "種目を登録しました。"
    else
      redirect_to exercises_path,
                  notice: "種目を登録しました。"
    end
  else
    render :new, status: :unprocessable_entity
  end
end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to exercises_path, notice: "種目を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @exercise.training_records.exists?
      redirect_to exercises_path,
                  alert: "トレーニング記録が存在する種目は削除できません。"
    else
      @exercise.destroy
      redirect_to exercises_path, notice: "種目を削除しました。"
    end
  end

  private

  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:name)
  end
end