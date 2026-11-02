class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise, only: [:edit, :update, :destroy]

  def index
    @exercises = Exercise.available_to(current_user).order(:name)
  end

  def new
    @exercise = current_user.exercises.new
  end

  def create
    @exercise = current_user.exercises.new(exercise_params)
    if @exercise.save
      redirect_to exercises_path, notice: "自分の種目を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @exercise.update(exercise_params)
      redirect_to exercises_path, notice: "種目を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @exercise.destroy
      redirect_to exercises_path, notice: "種目を削除しました。", status: :see_other
    else
      redirect_to exercises_path, alert: "記録に使われている種目は削除できません。", status: :see_other
    end
  end

  private

  def set_exercise
    @exercise = current_user.exercises.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:name)
  end
end
