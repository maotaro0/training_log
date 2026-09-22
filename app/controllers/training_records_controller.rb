class TrainingRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercises, only: [:new, :create, :edit, :update]
  
  def index
    @training_records = current_user.training_records.order(training_day: :desc)
  
  @chart_exercises = Exercise.joins(:training_records)
                           .where(training_records: { user_id: current_user.id })
                           .where.not(training_records: { weight_kg: nil })
                           .distinct
                           .order(:name)

  @selected_exercise = @chart_exercises.find_by(id: params[:exercise_id]) ||
                     @chart_exercises.first

  @chart_records =
    if @selected_exercise
      current_user.training_records
                .where(exercise_id: @selected_exercise.id)
                .where.not(weight_kg: nil)
                .order(:training_day)
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

  def edit
    @training_record = current_user.training_records.find(params[:id])
  end

  def new
    @training_record = TrainingRecord.new
  end

  def create
    @training_record = current_user.training_records.new(training_record_params)

    if @training_record.save
      redirect_to training_records_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
      @training_record = current_user.training_records.find(params[:id])

    if @training_record.update(training_record_params)
      redirect_to training_records_path
    else
     render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @training_record = current_user.training_records.find(params[:id])
    @training_record.destroy

    redirect_to training_records_path
  end


  private

    def set_exercises
      @exercises = Exercise.order(:name)
    end

  def training_record_params
    params.require(:training_record).permit(
      :training_day,
      :exercise_id,
      :weight_kg,
      :reps,
      :set_count
    )
  end

end